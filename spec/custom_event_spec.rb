RSpec.describe Lograge::CustomEvent do
  describe '.log' do
    let(:logger) { double('Logger', info: nil, error: nil) }

    before do
      Lograge.formatter = Lograge::Formatters::KeyValue.new
    end

    after do
      Lograge.logger = nil
    end

    context 'when Lograge.logger is configured' do
      before do
        Lograge.logger = logger
      end

      it 'uses the configured formatter and logs the message' do
        expect(logger).to receive(:info).with('some_key=some_value')

        Lograge::CustomEvent.log(some_key: 'some_value')
      end
    end

    context 'when Lograge.logger is not configured, but Rails is present' do
      let(:rails_logger) { double('Rails logger') }

      before do
        stub_const('Rails', double('Rails', logger: rails_logger))
      end

      it "uses Rails' logger" do
        expect(rails_logger).to receive(:info).with('some_key=some_value')

        Lograge::CustomEvent.log(some_key: 'some_value')
      end
    end

    context 'when neither Lograge.logger is configured nor Rails is there' do
      it 'raises an exception' do
        expect { Lograge::CustomEvent.log(some_key: 'some_value') }.to raise_error(RuntimeError)
      end
    end
  end
end
