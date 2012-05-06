require 'spec_helper'
require 'lograge'
require 'lograge/log_subscriber'
require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'logger'

describe Lograge::RequestLogSubscriber do
  let(:log_output) {StringIO.new}
  let(:logger) {
    logger = Logger.new(log_output)
    logger.formatter = ->(_, _, _, msg) {
      msg
    }
    logger
  }
  before do
    Lograge::RequestLogSubscriber.logger = logger
  end

  let(:subscriber) {Lograge::RequestLogSubscriber.new}
  let(:event) {
    ActiveSupport::Notifications::Event.new(
      'process_action.action_controller', Time.now, Time.now, 2, {
        status: 200, format: 'application/json', method: 'GET', path: '/home', params: {
          'controller' => 'home', 'action' => 'index'
        }, db_runtime: 0.02, view_runtime: 0.01
      }
    )
  }

  let(:redirect) {
    ActiveSupport::Notifications::Event.new(
      'redirect_to.action_controller', Time.now, Time.now, 1, location: 'http://example.com', status: 302
    )
  }

  describe "when processing an action" do
    it "should include the URL in the log output" do
      subscriber.process_action(event)
      log_output.string.should include('/home')
    end

    it "should start the log line with the HTTP method" do
      subscriber.process_action(event)
      log_output.string.starts_with?('GET').should == true
    end

    it "should include the status code" do
      subscriber.process_action(event)
      log_output.string.should include('status=200')
    end

    it "should include the controller and action" do
      subscriber.process_action(event)
      log_output.string.should include('action=home#index')
    end

    it "should include the duration" do
      subscriber.process_action(event)
      log_output.string.should =~ /duration=[\.0-9]{4,4}/
    end

    it "should include the view rendering time" do
      subscriber.process_action(event)
      log_output.string.should =~ /view=0.01/
    end

    it "should include the database rendering time" do
      subscriber.process_action(event)
      log_output.string.should =~ /db=0.02/
    end

    it "should add a 500 status when an exception occurred" do
      event.payload[:status] = nil
      event.payload[:exception] = ['AbstractController::ActionNotFound', 'Route not found']
      subscriber.process_action(event)
      log_output.string.should =~ /status=500/
      log_output.string.should =~ /error='AbstractController::ActionNotFound:Route not found'/
    end

    it "should return an unknown status when no status or exception is found" do
      event.payload[:status] = nil
      event.payload[:exception] = nil
      subscriber.process_action(event)
      log_output.string.should =~ /status=0/
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

  describe "with custom_options configured" do
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

  describe "when processing a redirect" do
    it "should store the location in a thread local variable" do
      subscriber.redirect_to(redirect)
      Thread.current[:lograge_location].should == "http://example.com"
    end
  end
end
