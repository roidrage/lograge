require 'spec_helper'
require 'lograge'
require 'lograge/log_subscriber'
require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'logger'

describe Lograge::RequestLogSubscriber do
  let(:log_output) {StringIO.new}
  let(:logger) {
    Logger.new(log_output).tap {|logger| logger.formatter = ->(_, _, _, msg) { msg } }
  }

  let(:subscriber) {Lograge::RequestLogSubscriber.new}
  let(:event) {
    ActiveSupport::Notifications::Event.new(
      'process_action.action_controller', Time.now, Time.now, 2, {
        status: 200, format: 'application/json', method: 'GET', path: '/home?foo=bar', params: {
          'controller' => 'home', 'action' => 'index', 'foo' => 'bar'
        }, db_runtime: 0.02, view_runtime: 0.01
      }
    )
  }
  let(:redirect) {
    ActiveSupport::Notifications::Event.new(
      'redirect_to.action_controller', Time.now, Time.now, 1, location: 'http://example.com', status: 302
    )
  }

  before { Lograge.logger = logger }

  describe "with custom_options configured for cee output" do
    before do
      Lograge::formatter = ->(data) { "My test: #{data}" }
    end

    it "should combine the hash properly for the output" do
      Lograge.custom_options = {:data => "value"}
      subscriber.process_action(event)
      log_output.string.should =~ /^My test: {.*:data=>"value"/
    end
    it "should combine the output of a lambda properly" do
      Lograge.custom_options = lambda {|event| {:data => "value"}}
      subscriber.process_action(event)
      log_output.string.should =~ /^My test: {.*:data=>"value"/
    end
    it "should work if the method returns nil" do
      Lograge.custom_options = lambda {|event| nil}
      subscriber.process_action(event)
      log_output.string.should be_present
    end
  end

  describe "when processing a redirect" do
    it "should store the location in a thread local variable" do
      subscriber.redirect_to(redirect)
      Thread.current[:lograge_location].should == "http://example.com"
    end
  end

  describe "when processing an action with lograge output" do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it "should include the URL in the log output" do
      subscriber.process_action(event)
      log_output.string.should include('/home')
    end

    it "should not include the query string in the url" do
      subscriber.process_action(event)
      log_output.string.should_not include('?foo=bar')
    end

    it "should start the log line with the HTTP method" do
      subscriber.process_action(event)
      log_output.string.starts_with?('method=GET ').should == true
    end

    it "should include the status code" do
      subscriber.process_action(event)
      log_output.string.should include('status=200 ')
    end

    it "should include the controller and action" do
      subscriber.process_action(event)
      log_output.string.should include('controller=home action=index')
    end

    it "should include the duration" do
      subscriber.process_action(event)
      log_output.string.should =~ /duration=[\.0-9]{4,4} /
    end

    it "should include the view rendering time" do
      subscriber.process_action(event)
      log_output.string.should =~ /view=0.01 /
    end

    it "should include the database rendering time" do
      subscriber.process_action(event)
      log_output.string.should =~ /db=0.02/
    end

    it "should add a 500 status when an exception occurred" do
      event.payload[:status] = nil
      event.payload[:exception] = ['AbstractController::ActionNotFound', 'Route not found']
      subscriber.process_action(event)
      log_output.string.should =~ /status=500 /
      log_output.string.should =~ /error='AbstractController::ActionNotFound:Route not found' /
    end

    it "should return an unknown status when no status or exception is found" do
      event.payload[:status] = nil
      event.payload[:exception] = nil
      subscriber.process_action(event)
      log_output.string.should =~ /status=0 /
    end

    describe "with a redirect" do
      before do
        Thread.current[:lograge_location] = "http://www.example.com"
      end

      it "should add the location to the log line" do
        subscriber.process_action(event)
        log_output.string.should =~ %r{ location=http://www.example.com}
      end

      it "should remove the thread local variable" do
        subscriber.process_action(event)
        Thread.current[:lograge_location].should == nil
      end
    end

    it "should not include a location by default" do
      subscriber.process_action(event)
      log_output.string.should_not =~ /location=/
    end
  end

  describe "with custom_options configured for lograge output" do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it "should combine the hash properly for the output" do
      Lograge.custom_options = {:data => "value"}
      subscriber.process_action(event)
      log_output.string.should =~ / data=value/
    end
    it "should combine the output of a lambda properly" do
      Lograge.custom_options = lambda {|event| {:data => "value"}}
      subscriber.process_action(event)
      log_output.string.should =~ / data=value/
    end
    it "should work if the method returns nil" do
      Lograge.custom_options = lambda {|event| nil}
      subscriber.process_action(event)
      log_output.string.should be_present
    end
  end

  describe "with ignore configured" do
    before do
      # Lograge::log_format = :lograge
      Lograge::ignore_nothing # clear the old ignores before each test
    end

    it "should not log ignored controller actions given a single ignored action" do
      Lograge.ignore_actions 'home#index'
      subscriber.process_action(event)
      log_output.string.should  be_blank
    end

    it "should not log ignored controller actions given a single ignored action after a custom ignore" do
      Lograge.ignore(lambda {|event| false})
      Lograge.ignore_actions 'home#index'
      subscriber.process_action(event)
      log_output.string.should be_blank
    end

    it "should log non-ignored controller actions given a single ignored action" do
      Lograge.ignore_actions 'foo#bar'
      subscriber.process_action(event)
      log_output.string.should_not be_blank
    end

    it "should not log ignored controller actions given multiple ignored actions" do
      Lograge.ignore_actions ['foo#bar', 'home#index', 'bar#foo']
      subscriber.process_action(event)
      log_output.string.should be_blank
    end

    it "should log non-ignored controller actions given multiple ignored actions" do
      Lograge.ignore_actions ['foo#bar', 'bar#foo']
      subscriber.process_action(event)
      log_output.string.should_not be_blank
    end

    it "should not log ignored events" do
      Lograge.ignore(lambda do |event|
        'GET' == event.payload[:method]
      end)
      subscriber.process_action(event)
      log_output.string.should be_blank
    end

    it "should log non-ignored events" do
      Lograge.ignore(lambda do |event|
        'foo' == event.payload[:method]
      end)
      subscriber.process_action(event)
      log_output.string.should_not be_blank
    end

    it "should not choke on nil ignore_actions input" do
      Lograge.ignore_actions nil
      subscriber.process_action(event)
      log_output.string.should_not be_blank
    end

    it "should not choke on nil ignore input" do
      Lograge.ignore nil
      subscriber.process_action(event)
      log_output.string.should_not be_blank
    end
  end

  it "should fallback to ActiveSupport's logger if one isn't configured" do
    Lograge.formatter = Lograge::Formatters::KeyValue.new
    Lograge.logger = nil
    ActiveSupport::LogSubscriber.logger = logger

    subscriber.process_action(event)

    log_output.string.should be_present
  end
end
