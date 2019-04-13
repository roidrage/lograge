describe Lograge::Formatters::Helpers::MethodAndPath do
  describe '#method_and_path_string' do
    let(:instance) do
      Object.new.extend(described_class)
    end

    let(:method_and_path_string) { instance.method_and_path_string(data) }

    context "when both 'method' and 'path' fields are blank" do
      let(:data) { {} }

      it 'returns single space' do
        expect(method_and_path_string).to eq(' ')
      end
    end

    context "when 'method' field is present" do
      let(:data) { { method: 'GET' } }

      it "returns 'method' value surrounded with spaces" do
        expect(method_and_path_string).to eq(' GET ')
      end
    end

    context "when 'path' field is present" do
      let(:data) { { path: '/foo' } }

      it "returns 'path' value surrounded by spaces" do
        expect(method_and_path_string).to eq(' /foo ')
      end
    end

    context "when both 'method' and path' fields are present" do
      let(:data) { { method: 'index', path: '/foo' } }

      it 'returns string surrounded by spaces with both fields separated with a space ' do
        expect(method_and_path_string).to eq(' index /foo ')
      end
    end
  end
end
