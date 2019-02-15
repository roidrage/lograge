require 'active_support/notifications'
require 'active_support/core_ext/string'
require 'active_support/deprecation'
require 'active_support/log_subscriber'
require 'action_controller/log_subscriber'
require 'action_view/log_subscriber'

describe Lograge do
  context "when removing Rails' log subscribers" do
    after do
      ActionController::LogSubscriber.attach_to :action_controller
      ActionView::LogSubscriber.attach_to :action_view
    end

    it 'removes subscribers for controller events' do
      expect do
        Lograge.remove_existing_log_subscriptions
      end.to change {
        ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller')
      }
    end

    it 'removes subscribers for all events' do
      expect do
        Lograge.remove_existing_log_subscriptions
      end.to change {
        ActiveSupport::Notifications.notifier.listeners_for('render_template.action_view')
      }
    end

    it "does not remove subscribers that aren't from Rails" do
      blk = -> {}
      ActiveSupport::Notifications.subscribe('process_action.action_controller', &blk)
      Lograge.remove_existing_log_subscriptions
      listeners = ActiveSupport::Notifications.notifier.listeners_for('process_action.action_controller')
      expect(listeners.size).to eq(1)
    end
  end

  describe 'keep_original_rails_log option' do
    context 'when keep_original_rails_log is true' do
      let(:app_config) do
        double(config:
                ActiveSupport::OrderedOptions.new.tap do |config|
                  config.action_dispatch = double(rack_cache: false)
                  config.lograge = ActiveSupport::OrderedOptions.new
                  config.lograge.keep_original_rails_log = true
                end)
      end

      it "does not remove Rails' subscribers" do
        expect(Lograge).to_not receive(:remove_existing_log_subscriptions)
        Lograge.setup(app_config)
      end
    end
  end

  describe 'disabling rack_cache verbosity' do
    subject { -> { Lograge.setup(app_config) } }
    let(:app_config) do
      double(config:
              ActiveSupport::OrderedOptions.new.tap do |config|
                config.action_dispatch = config_option
                config.lograge = ActiveSupport::OrderedOptions.new
                config.lograge.keep_original_rails_log = true
              end)
    end
    let(:config_option) { double(rack_cache: rack_cache) }

    context 'when rack_cache is false' do
      let(:rack_cache) { false }

      it 'does not change config option' do
        expect(subject).to_not change { config_option.rack_cache }
      end
    end

    context 'when rack_cache is a hash' do
      let(:rack_cache) { { foo: 'bar', verbose: true } }

      it 'sets verbose to false' do
        expect(subject).to change { config_option.rack_cache[:verbose] }.to(false)
      end
    end

    context 'when rack_cache is true' do
      let(:rack_cache) { true }

      it 'does not change config option' do
        expect(subject).to_not change { config_option.rack_cache }
      end
    end
  end

  describe 'handling custom_payload option' do
    let(:controller_class) { 'ActionController::Base' }
    let(:app_config) do
      config_obj = ActiveSupport::OrderedOptions.new.tap do |config|
        config.action_dispatch = double(rack_cache: false)
        config.lograge = Lograge::OrderedOptions.new
        config.lograge.custom_payload do |c|
          { user_id: c.current_user_id }
        end
      end
      double(config: config_obj)
    end
    let(:controller) do
      Class.new do
        def append_info_to_payload(payload)
          payload.merge!(appended: true)
        end

        def current_user_id
          '24601'
        end
      end
    end
    let(:payload) { { timestamp: Date.parse('5-11-1955') } }

    subject { payload.dup }

    before do
      stub_const(controller_class, controller)
      Lograge.setup(app_config)
      controller_class.constantize.new.append_info_to_payload(subject)
    end

    it { should eq(payload.merge(appended: true, custom_payload: { user_id: '24601' })) }

    context 'when base_controller_class option is set' do
      let(:controller_class) { 'ActionController::API' }
      let(:base_controller_class) { controller_class }
      let(:app_config) do
        config_obj = ActiveSupport::OrderedOptions.new.tap do |config|
          config.action_dispatch = double(rack_cache: false)
          config.lograge = Lograge::OrderedOptions.new
          config.lograge.base_controller_class = base_controller_class
          config.lograge.custom_payload do |c|
            { user_id: c.current_user_id }
          end
        end
        double(config: config_obj)
      end

      it { should eq(payload.merge(appended: true, custom_payload: { user_id: '24601' })) }

      context 'when base_controller_class is an array' do
        let(:base_controller_class) { [controller_class] }

        it { should eq(payload.merge(appended: true, custom_payload: { user_id: '24601' })) }
      end
    end
  end

  describe 'deprecated log_format interpreter' do
    let(:app_config) do
      double(config:
              ActiveSupport::OrderedOptions.new.tap do |config|
                config.action_dispatch = double(rack_cache: false)
                config.lograge = ActiveSupport::OrderedOptions.new
                config.lograge.log_format = format
              end)
    end
    before { ActiveSupport::Deprecation.silence { Lograge.setup(app_config) } }
    subject { Lograge.formatter }

    context ':cee' do
      let(:format) { :cee }

      it 'is an instance of Lograge::Formatters::Cee' do
        expect(subject).to be_instance_of(Lograge::Formatters::Cee)
      end
    end

    context ':raw' do
      let(:format) { :raw }

      it 'is an instance of Lograge::Formatters::Raw' do
        expect(subject).to be_instance_of(Lograge::Formatters::Raw)
      end
    end

    context ':logstash' do
      let(:format) { :logstash }

      it 'is an instance of Lograge::Formatters::Logstash' do
        expect(subject).to be_instance_of(Lograge::Formatters::Logstash)
      end
    end

    context ':graylog2' do
      let(:format) { :graylog2 }

      it 'is an instance of Lograge::Formatters::Graylog2' do
        expect(subject).to be_instance_of(Lograge::Formatters::Graylog2)
      end
    end

    context ':lograge' do
      let(:format) { :lograge }

      it 'is an instance of Lograge::Formatters::KeyValue' do
        expect(subject).to be_instance_of(Lograge::Formatters::KeyValue)
      end
    end

    context 'default' do
      let(:format) { nil }

      it 'is an instance of Lograge::Formatters::KeyValue' do
        expect(subject).to be_instance_of(Lograge::Formatters::KeyValue)
      end
    end
  end

  describe 'handling exceptions' do
    let(:app_config) do
      double(config:
        ActiveSupport::OrderedOptions.new.tap do |config|
          config.action_dispatch = double(rack_cache: false)
          config.lograge = ActiveSupport::OrderedOptions.new
        end)
    end
    let(:debug_exceptions) do
      # Workaround `undefined method 'blamed_files'` bug
      require 'active_support/dependencies'
      # Workaround `undefined method 'with_indifferent_access'` bug:
      # https://github.com/rails/rails/issues/33634
      require 'active_support/core_ext/hash/indifferent_access'
      ActionDispatch::DebugExceptions.new(->(_) { raise })
    end
    let(:output) { StringIO.new }
    let(:logger) { Logger.new(output) }
    let(:env) do
      Rack::MockRequest.env_for(
        '',
        'action_dispatch.show_detailed_exceptions' => true,
        'action_dispatch.logger' => logger
      )
    end

    before do
      Lograge.setup(app_config)
      Lograge.logger = logger
    end

    it 'adds formatted exception log' do
      debug_exceptions.call(env)
      expect(output.string).to match(/status=500 error='RuntimeError: '/)
    end

    it 'removes original exception log' do
      debug_exceptions.call(env)
      expect(output.string).not_to match(/FATAL -- : RuntimeError/)
    end

    context 'when keep_original_rails_log is true' do
      before do
        app_config.config.lograge.keep_original_rails_log = true
      end

      it 'adds formatted exception log' do
        debug_exceptions.call(env)
        expect(output.string).to match(/status=500 error='RuntimeError: '/)
      end

      it 'keeps original exception log' do
        debug_exceptions.call(env)
        expect(output.string).to match(/FATAL -- : RuntimeError/)
      end
    end
  end
end
