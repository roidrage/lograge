# frozen_string_literal: true

require 'lograge/log_subscribers/action_controller'
require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'logger'
require 'active_record'
require 'rails'

describe Lograge::LogSubscribers::ActionController do
  let(:log_output) { JSON.parse(io_target.string, symbolize_names: true) }
  let(:io_target) { StringIO.new }
  let(:logger) do
    Logger.new(io_target).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end

  let(:subscriber) { Lograge::LogSubscribers::ActionController.new }
  let(:event_params) { { 'foo' => 'bar' } }

  let(:event) do
    ActiveSupport::Notifications::Event.new(
      'process_action.action_controller',
      Time.now,
      Time.now,
      2,
      status: 200,
      controller: 'HomeController',
      action: 'index',
      format: 'application/json',
      method: 'GET',
      path: '/home?foo=bar',
      params: event_params,
      request: ActionDispatch::Request.new(
        {
          'HTTP_USER_AGENT' => 'Google Chrome',
          'PATH_INFO' => '/home',
          'QUERY_STRING' => 'foo=bar',
          'REMOTE_ADDR' => '127.0.0.1',
          'REQUEST_URI' => 'http://localhost/'
        }
      ),
      db_runtime: 0.02,
      view_runtime: 0.01
    )
  end

  before do
    Lograge.logger = logger
    Lograge.formatter = Lograge::Formatters::Json.new
  end

  context 'with custom_options configured for cee output' do
    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.process_action(event)
      expect(log_output[:data]).to eq('value')
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.process_action(event)
      expect(log_output[:data]).to eq('value')
    end

    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) {}

      subscriber.process_action(event)
      expect(log_output).to be_present
    end
  end

  context 'when processing a redirect' do
    let(:redirect_event) do
      ActiveSupport::Notifications::Event.new(
        'redirect_to.action_controller',
        Time.now,
        Time.now,
        1,
        location: 'http://example.com',
        status: 302,
        request: ActionDispatch::Request.new('test')
      )
    end

    it 'stores the location in a thread local variable' do
      subscriber.redirect_to(redirect_event)
      expect(RequestStore.store[:lograge_location]).to eq('http://example.com')
    end
  end

  context 'when processing unpermitted parameters' do
    let(:unpermitted_parameters_event) do
      ActiveSupport::Notifications::Event.new(
        'unpermitted_parameters.action_controller',
        Time.now,
        Time.now,
        1,
        keys: %w[foo bar]
      )
    end

    it 'stores the parameters in a thread local variable' do
      subscriber.unpermitted_parameters(unpermitted_parameters_event)
      expect(RequestStore.store[:lograge_unpermitted_params]).to eq(%w[foo bar])
    end
  end

  context 'when processing an action with lograge output' do
    it 'includes the URL in the log output' do
      subscriber.process_action(event)
      expect(log_output[:http][:url]).to include('/home')
    end

    it 'includes the query string in the url' do
      subscriber.process_action(event)
      expect(log_output[:http][:url]).to include('?foo=bar')
    end

    it 'includes the HTTP method in the log output' do
      subscriber.process_action(event)
      expect(log_output[:http][:method]).to eq('GET')
    end

    it 'includes the status code' do
      subscriber.process_action(event)
      expect(log_output[:http][:status_code]).to eq(200)
    end

    it 'includes the controller' do
      subscriber.process_action(event)
      expect(log_output[:controller]).to eq('HomeController')
    end

    it 'includes the action' do
      subscriber.process_action(event)
      expect(log_output[:action]).to eq('index')
    end

    it 'includes the duration' do
      subscriber.process_action(event)
      expect(log_output[:duration].to_s).to match(/[.0-9]{3}/)
    end

    it 'includes the view rendering time' do
      subscriber.process_action(event)
      expect(log_output[:view].to_s).to match(/0.01/)
    end

    it 'includes the database rendering time' do
      subscriber.process_action(event)
      expect(log_output[:db].to_s).to match(/0.02/)
    end

    it 'includes the timestamp' do
      subscriber.process_action(event)
      expect(log_output[:timestamp]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/)
    end

    it 'includes the client ip' do
      subscriber.process_action(event)
      expect(log_output[:network][:client][:ip]).to eq('127.0.0.1')
    end

    context 'when an `ActiveRecord::RecordNotFound` is raised' do
      let(:exception) do
        ActiveRecord::RecordNotFound.new('Record not found').tap do |e|
          e.set_backtrace(['some location', 'another location'])
        end
      end

      before do
        ActionDispatch::ExceptionWrapper.rescue_responses[exception.class.name] = :not_found
        event.payload[:exception_object] = exception
        event.payload[:status] = nil
      end

      it 'adds a 404 status' do
        subscriber.process_action(event)
        expect(log_output[:http][:status_code]).to eq(404)
        expect(log_output[:error][:kind]).to eq('ActiveRecord::RecordNotFound')
        expect(log_output[:error][:message]).to eq('Record not found')
        expect(log_output[:error][:stack]).to eq("some location\nanother location")
      end
    end

    it 'returns an unknown status when no status or exception is found' do
      event.payload[:status] = nil
      event.payload[:exception_object] = nil
      subscriber.process_action(event)
      expect(log_output[:http][:status_code]).to eq(0)
    end

    context 'with a redirect' do
      before do
        RequestStore.store[:lograge_location] = 'http://www.example.com?key=value'
      end

      it 'adds the location to the log line' do
        subscriber.process_action(event)
        expect(log_output[:location]).to eq('http://www.example.com')
      end

      it 'removes the thread local variable' do
        subscriber.process_action(event)
        expect(RequestStore.store[:lograge_location]).to be_nil
      end
    end

    it 'does not include a location by default' do
      subscriber.process_action(event)
      expect(log_output[:location]).to be_nil
    end

    context 'with unpermitted_parameters' do
      before do
        RequestStore.store[:lograge_unpermitted_params] = %w[florb blarf]
      end

      it 'adds the unpermitted_params to the log line' do
        subscriber.process_action(event)
        expect(log_output[:unpermitted_params]).to match_array(%w[florb blarf])
      end

      it 'removes the thread local variable' do
        subscriber.process_action(event)
        expect(RequestStore.store[:lograge_unpermitted_params]).to be_nil
      end
    end

    it 'does not include unpermitted_params by default' do
      subscriber.process_action(event)
      expect(log_output[:unpermitted_params]).to be_nil
    end
  end

  context 'with custom_options configured for lograge output' do
    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.process_action(event)
      expect(log_output[:data]).to eq('value')
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.process_action(event)
      expect(log_output[:data]).to eq('value')
    end
    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) {}

      subscriber.process_action(event)
      expect(log_output).to_not be_empty
    end
  end

  context 'when event payload includes a "custom_payload"' do
    it 'incorporates the payload correctly' do
      event.payload[:custom_payload] = { data: 'value' }

      subscriber.process_action(event)
      expect(log_output[:data]).to eq('value')
    end

    it 'works when custom_payload is nil' do
      event.payload[:custom_payload] = nil

      subscriber.process_action(event)
      expect(log_output).to_not be_empty
    end
  end

  context 'with before_format configured for lograge output' do
    before do
      Lograge.before_format = nil
    end

    it 'outputs correctly' do
      Lograge.before_format = ->(data, payload) { Hash[*data.first].merge(Hash[*payload.first]) }

      subscriber.process_action(event)

      expect(log_output[:format]).to eq('application/json')
      expect(log_output[:status]).to eq(200)
    end
    it 'works if the method returns nil' do
      Lograge.before_format = ->(_data, _payload) {}

      subscriber.process_action(event)
      expect(log_output).to_not be_empty
    end
  end

  context 'with ignore configured' do
    before do
      Lograge.ignore_nothing
    end

    it 'does not log ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'HomeController#index'
      subscriber.process_action(event)
      expect(io_target.string).to be_empty
    end

    it 'does not log ignored controller actions given a single ignored action after a custom ignore' do
      Lograge.ignore(->(_event) { false })

      Lograge.ignore_actions 'HomeController#index'
      subscriber.process_action(event)
      expect(io_target.string).to be_blank
    end

    it 'logs non-ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'FooController#bar'
      subscriber.process_action(event)
      expect(io_target.string).to be_present
    end

    it 'does not log ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['FooController#bar', 'HomeController#index', 'BarController#foo']
      subscriber.process_action(event)
      expect(io_target.string).to be_blank
    end

    it 'logs non-ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['FooController#bar', 'BarController#foo']
      subscriber.process_action(event)
      expect(io_target.string).to_not be_blank
    end

    it 'does not log ignored events' do
      Lograge.ignore(->(event) { event.payload[:method] == 'GET' })

      subscriber.process_action(event)
      expect(io_target.string).to be_blank
    end

    it 'logs non-ignored events' do
      Lograge.ignore(->(event) { event.payload[:method] == 'foo' })

      subscriber.process_action(event)
      expect(log_output).not_to be_empty
    end

    it 'does not choke on nil ignore_actions input' do
      Lograge.ignore_actions nil
      subscriber.process_action(event)
      expect(log_output).not_to be_empty
    end

    it 'does not choke on nil ignore input' do
      Lograge.ignore nil
      subscriber.process_action(event)
      expect(log_output).not_to be_empty
    end
  end

  it "will fallback to ActiveSupport's logger if one isn't configured" do
    Lograge.logger = nil
    ActiveSupport::LogSubscriber.logger = logger

    subscriber.process_action(event)

    expect(io_target.string).to be_present
  end
end
