require 'lograge/log_subscriber'
require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'logger'
require 'active_record'
require 'rails'

describe Lograge::RequestLogSubscriber do
  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end

  let(:subscriber) { Lograge::RequestLogSubscriber.new }
  let(:event_params) { { 'foo' => 'bar' } }

  let(:event) do
    ActiveSupport::Notifications::Event.new(
      'process_action.action_controller',
      Time.now,
      Time.now,
      2,
      status: 200,
      controller: 'home',
      action: 'index',
      format: 'application/json',
      method: 'GET',
      path: '/home?foo=bar',
      params: event_params,
      db_runtime: 0.02,
      view_runtime: 0.01
    )
  end

  before { Lograge.logger = logger }

  context 'with custom_options configured for cee output' do
    before do
      Lograge.formatter = ->(data) { "My test: #{data}" }
    end

    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.process_action(event)
      expect(log_output.string).to match(/^My test: {.*:data=>"value"/)
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.process_action(event)
      expect(log_output.string).to match(/^My test: {.*:data=>"value"/)
    end

    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) { nil }

      subscriber.process_action(event)
      expect(log_output.string).to be_present
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
        status: 302
      )
    end

    it 'stores the location in a thread local variable' do
      subscriber.redirect_to(redirect_event)
      expect(Thread.current[:lograge_location]).to eq('http://example.com')
    end
  end

  context 'when processing unpermitted parameters' do
    let(:unpermitted_parameters_event) do
      ActiveSupport::Notifications::Event.new(
        'unpermitted_parameters.action_controller',
        Time.now,
        Time.now,
        1,
        keys: %w(foo bar)
      )
    end

    it 'stores the parameters in a thread local variable' do
      subscriber.unpermitted_parameters(unpermitted_parameters_event)
      expect(Thread.current[:lograge_unpermitted_params]).to eq(%w(foo bar))
    end
  end

  context 'when processing an action with lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it 'includes the URL in the log output' do
      subscriber.process_action(event)
      expect(log_output.string).to include('/home')
    end

    it 'does not include the query string in the url' do
      subscriber.process_action(event)
      expect(log_output.string).not_to include('?foo=bar')
    end

    it 'starts the log line with the HTTP method' do
      subscriber.process_action(event)
      expect(log_output.string).to match(/^method=GET /)
    end

    it 'includes the status code' do
      subscriber.process_action(event)
      expect(log_output.string).to include('status=200 ')
    end

    it 'includes the controller and action' do
      subscriber.process_action(event)
      expect(log_output.string).to include('controller=home action=index')
    end

    it 'includes the duration' do
      subscriber.process_action(event)
      expect(log_output.string).to match(/duration=[\.0-9]{4,4} /)
    end

    it 'includes the view rendering time' do
      subscriber.process_action(event)
      expect(log_output.string).to match(/view=0.01 /)
    end

    it 'includes the database rendering time' do
      subscriber.process_action(event)
      expect(log_output.string).to match(/db=0.02/)
    end

    context 'when an `ActiveRecord::RecordNotFound` is raised' do
      let(:exception) { 'ActiveRecord::RecordNotFound' }

      before do
        ActionDispatch::ExceptionWrapper.rescue_responses[exception] = :not_found
        event.payload[:exception] = [exception, 'Record not found']
        event.payload[:status] = nil
      end

      it 'adds a 404 status' do
        subscriber.process_action(event)
        expect(log_output.string).to match(/status=404 /)
        expect(log_output.string).to match(
          /error='ActiveRecord::RecordNotFound: Record not found' /
        )
      end
    end

    it 'returns an unknown status when no status or exception is found' do
      event.payload[:status] = nil
      event.payload[:exception] = nil
      subscriber.process_action(event)
      expect(log_output.string).to match(/status=0 /)
    end

    context 'with a redirect' do
      before do
        Thread.current[:lograge_location] = 'http://www.example.com'
      end

      it 'adds the location to the log line' do
        subscriber.process_action(event)
        expect(log_output.string).to match(%r{location=http://www.example.com})
      end

      it 'removes the thread local variable' do
        subscriber.process_action(event)
        expect(Thread.current[:lograge_location]).to be_nil
      end
    end

    it 'does not include a location by default' do
      subscriber.process_action(event)
      expect(log_output.string).to_not include('location=')
    end

    context 'with unpermitted_parameters' do
      before do
        Thread.current[:lograge_unpermitted_params] = %w(florb blarf)
      end

      it 'adds the unpermitted_params to the log line' do
        subscriber.process_action(event)
        expect(log_output.string).to include('unpermitted_params=["florb", "blarf"]')
      end

      it 'removes the thread local variable' do
        subscriber.process_action(event)
        expect(Thread.current[:lograge_unpermitted_params]).to be_nil
      end
    end

    it 'does not include unpermitted_params by default' do
      subscriber.process_action(event)
      expect(log_output.string).to_not include('unpermitted_params=')
    end
  end

  context 'with custom_options configured for lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.process_action(event)
      expect(log_output.string).to match(/ data=value/)
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.process_action(event)
      expect(log_output.string).to match(/ data=value/)
    end
    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) { nil }

      subscriber.process_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'with before_format configured for lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
      Lograge.before_format = nil
    end

    it 'outputs correctly' do
      Lograge.before_format = ->(data, payload) { Hash[*data.first].merge(Hash[*payload.first]) }

      subscriber.process_action(event)

      expect(log_output.string).to include('method=GET')
      expect(log_output.string).to include('status=200')
    end
    it 'works if the method returns nil' do
      Lograge.before_format = ->(_data, _payload) { nil }

      subscriber.process_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'with ignore configured' do
    before do
      Lograge.ignore_nothing
    end

    it 'does not log ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'home#index'
      subscriber.process_action(event)
      expect(log_output.string).to be_blank
    end

    it 'does not log ignored controller actions given a single ignored action after a custom ignore' do
      Lograge.ignore(->(_event) { false })

      Lograge.ignore_actions 'home#index'
      subscriber.process_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'foo#bar'
      subscriber.process_action(event)
      expect(log_output.string).to be_present
    end

    it 'does not log ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['foo#bar', 'home#index', 'bar#foo']
      subscriber.process_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['foo#bar', 'bar#foo']
      subscriber.process_action(event)
      expect(log_output.string).to_not be_blank
    end

    it 'does not log ignored events' do
      Lograge.ignore(->(event) { 'GET' == event.payload[:method] })

      subscriber.process_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored events' do
      Lograge.ignore(->(event) { 'foo' == event.payload[:method] })

      subscriber.process_action(event)
      expect(log_output.string).not_to be_blank
    end

    it 'does not choke on nil ignore_actions input' do
      Lograge.ignore_actions nil
      subscriber.process_action(event)
      expect(log_output.string).not_to be_blank
    end

    it 'does not choke on nil ignore input' do
      Lograge.ignore nil
      subscriber.process_action(event)
      expect(log_output.string).not_to be_blank
    end
  end

  it "will fallback to ActiveSupport's logger if one isn't configured" do
    Lograge.formatter = Lograge::Formatters::KeyValue.new
    Lograge.logger = nil
    ActiveSupport::LogSubscriber.logger = logger

    subscriber.process_action(event)

    expect(log_output.string).to be_present
  end
end
