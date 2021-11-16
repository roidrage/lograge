# frozen_string_literal: true

require 'lograge/log_subscribers/action_controller'
require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'logger'
require 'active_record'
require 'rails'

describe Lograge::LogSubscribers::ActionCable do
  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end

  let(:subscriber) { Lograge::LogSubscribers::ActionCable.new }
  let(:event_params) { { 'foo' => 'bar' } }

  let(:event) do
    ActiveSupport::Notifications::Event.new(
      'perform_action.action_cable',
      Time.now,
      Time.now,
      2,
      channel_class: 'ActionCableChannel',
      data: event_params,
      action: 'pong'
    )
  end

  before { Lograge.logger = logger }

  context 'with custom_options configured for cee output' do
    before do
      Lograge.formatter = ->(data) { "My test: #{data}" }
    end

    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.perform_action(event)
      expect(log_output.string).to match(/^My test: {.*:data=>"value"/)
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.perform_action(event)
      expect(log_output.string).to match(/^My test: {.*:data=>"value"/)
    end

    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) {}

      subscriber.perform_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'when processing an action with lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it 'includes the controller and action' do
      subscriber.perform_action(event)
      expect(log_output.string).to include('controller=ActionCableChannel action=pong')
    end

    it 'includes the duration' do
      subscriber.perform_action(event)
      expect(log_output.string).to match(/duration=[.0-9]{2,4}/)
    end

    context 'when an `ActiveRecord::RecordNotFound` is raised' do
      let(:exception) { 'ActiveRecord::RecordNotFound' }

      before do
        ActionDispatch::ExceptionWrapper.rescue_responses[exception] = :not_found
        event.payload[:exception] = [exception, 'Record not found']
        event.payload[:status] = nil
      end

      it 'adds a 404 status' do
        subscriber.perform_action(event)
        expect(log_output.string).to match(/status=404 /)
        expect(log_output.string).to match(
          /error='ActiveRecord::RecordNotFound: Record not found' /
        )
      end
    end

    it 'returns a default status when no status or exception is found' do
      event.payload[:status] = nil
      event.payload[:exception] = nil
      subscriber.perform_action(event)
      expect(log_output.string).to match(/status=200 /)
    end

    it 'does not include a location by default' do
      subscriber.perform_action(event)
      expect(log_output.string).to_not include('location=')
    end
  end

  context 'with custom_options configured for lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it 'combines the hash properly for the output' do
      Lograge.custom_options = { data: 'value' }
      subscriber.perform_action(event)
      expect(log_output.string).to match(/ data=value/)
    end

    it 'combines the output of a lambda properly' do
      Lograge.custom_options = ->(_event) { { data: 'value' } }

      subscriber.perform_action(event)
      expect(log_output.string).to match(/ data=value/)
    end
    it 'works when the method returns nil' do
      Lograge.custom_options = ->(_event) {}

      subscriber.perform_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'when event payload includes a "custom_payload"' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    it 'incorporates the payload correctly' do
      event.payload[:custom_payload] = { data: 'value' }

      subscriber.perform_action(event)
      expect(log_output.string).to match(/ data=value/)
    end

    it 'works when custom_payload is nil' do
      event.payload[:custom_payload] = nil

      subscriber.perform_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'with before_format configured for lograge output' do
    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
      Lograge.before_format = nil
    end

    it 'outputs correctly' do
      Lograge.before_format = ->(data, payload) { { status: data[:status] }.merge(action: payload[:action]) }

      subscriber.perform_action(event)

      expect(log_output.string).to include('action=pong')
      expect(log_output.string).to include('status=200')
    end
    it 'works if the method returns nil' do
      Lograge.before_format = ->(_data, _payload) {}

      subscriber.perform_action(event)
      expect(log_output.string).to be_present
    end
  end

  context 'with ignore configured' do
    before do
      Lograge.ignore_nothing
    end

    it 'does not log ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'ActionCableChannel#pong'
      subscriber.perform_action(event)
      expect(log_output.string).to be_blank
    end

    it 'does not log ignored controller actions given a single ignored action after a custom ignore' do
      Lograge.ignore(->(_event) { false })

      Lograge.ignore_actions 'ActionCableChannel#pong'
      subscriber.perform_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored controller actions given a single ignored action' do
      Lograge.ignore_actions 'ActionCableChannel#bar'
      subscriber.perform_action(event)
      expect(log_output.string).to be_present
    end

    it 'does not log ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['ActionCableChannel#bar', 'ActionCableChannel#pong', 'OtherChannel#foo']
      subscriber.perform_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored controller actions given multiple ignored actions' do
      Lograge.ignore_actions ['ActionCableChannel#bar', 'OtherChannel#foo']
      subscriber.perform_action(event)
      expect(log_output.string).to_not be_blank
    end

    it 'does not log ignored events' do
      Lograge.ignore(->(event) { event.payload[:action] == 'pong' })

      subscriber.perform_action(event)
      expect(log_output.string).to be_blank
    end

    it 'logs non-ignored events' do
      Lograge.ignore(->(event) { event.payload[:action] == 'foo' })

      subscriber.perform_action(event)
      expect(log_output.string).not_to be_blank
    end

    it 'does not choke on nil ignore_actions input' do
      Lograge.ignore_actions nil
      subscriber.perform_action(event)
      expect(log_output.string).not_to be_blank
    end

    it 'does not choke on nil ignore input' do
      Lograge.ignore nil
      subscriber.perform_action(event)
      expect(log_output.string).not_to be_blank
    end
  end

  describe 'other actions' do
    %i[subscribe unsubscribe connect disconnect].each do |action_name|
      let(:event) do
        ActiveSupport::Notifications::Event.new(
          "#{action_name}.action_cable",
          Time.now,
          Time.now,
          2,
          channel_class: 'ActionCableChannel',
          data: event_params,
          action: 'pong'
        )
      end

      it 'generates output' do
        subscriber.perform_action(event)
        expect(log_output.string).to include('controller=ActionCableChannel action=pong')
      end
    end
  end

  it "will fallback to ActiveSupport's logger if one isn't configured" do
    Lograge.formatter = Lograge::Formatters::KeyValue.new
    Lograge.logger = nil
    ActiveSupport::LogSubscriber.logger = logger

    subscriber.perform_action(event)

    expect(log_output.string).to be_present
  end
end
