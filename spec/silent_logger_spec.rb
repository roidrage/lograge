# frozen_string_literal: true

require 'logger'

describe Lograge::SilentLogger do
  let(:base_logger) { Logger.new($stdout) }
  subject(:silent_logger) { described_class.new(base_logger) }

  it "doesn't call base logger on either log method" do
    %i[debug info warn error fatal unknown].each do |method_name|
      expect(base_logger).not_to receive(method_name)

      silent_logger.public_send(method_name)
    end
  end
end
