require 'spec_helper'
require 'lograge'
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

  describe 'deprecated log_format interpreter' do
    let(:app_config) do
      double(config:
        ActiveSupport::OrderedOptions.new.tap do |config|
          config.action_dispatch = double(rack_cache: false)
          config.lograge = ActiveSupport::OrderedOptions.new
          config.lograge.log_format = format
        end
      )
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
end
