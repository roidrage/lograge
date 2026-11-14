# frozen_string_literal: true

describe Lograge::Formatters::Helpers::SafeJson do
  let(:replacement) { [0xFFFD].pack('U') } # U+FFFD REPLACEMENT CHARACTER
  let(:binary_utf8) { '不正な値です。'.b }
  let(:invalid_utf8) { "abc\xFFdef".dup.force_encoding(Encoding::UTF_8) }
  let(:invalid_binary) { "abc\xFF\xFEdef".b }

  describe '.dump' do
    it 'serializes well formed data' do
      expect(described_class.dump(status: 200, path: '/')).to eq('{"status":200,"path":"/"}')
    end

    it 'serializes non-ASCII binary strings that hold valid UTF-8' do
      output = described_class.dump(error: "StandardError: #{binary_utf8}")
      expect(JSON.parse(output)).to eq('error' => 'StandardError: 不正な値です。')
    end

    it 'replaces bytes that are not valid UTF-8' do
      expect(JSON.parse(described_class.dump(params: invalid_utf8))).to eq('params' => "abc#{replacement}def")
    end

    it 'keeps the last value for keys that serialize to the same name' do
      expect(JSON.parse(described_class.dump(:status => 200, 'status' => 'ok'))).to eq('status' => 'ok')
    end

    it 'serializes exceptions whose message holds non-ASCII binary bytes' do
      output = described_class.dump(exception_object: StandardError.new(binary_utf8))
      expect(JSON.parse(output)).to eq('exception_object' => '不正な値です。')
    end

    it 'serializes symbols that hold non-ASCII binary bytes' do
      expect(JSON.parse(described_class.dump(value: binary_utf8.to_sym))).to eq('value' => '不正な値です。')
    end

    it 'serializes strings in dummy encodings that have no converter' do
      output = described_class.dump(value: '+ZeVnLIqe-'.dup.force_encoding(Encoding::UTF_7), bad: invalid_utf8)
      expect(JSON.parse(output)).to eq('value' => '+ZeVnLIqe-', 'bad' => "abc#{replacement}def")
    end

    it 'raises with the original error as the cause if the retry also fails' do
      allow(JSON).to receive(:dump).and_raise(JSON::GeneratorError, 'first')

      expect { described_class.dump(status: 200) }.to raise_error(JSON::GeneratorError) { |error|
        expect(error.cause).to be_a(JSON::GeneratorError)
      }
    end

    it 'does not modify the data it was given' do
      data = { error: binary_utf8, nested: [{ params: invalid_utf8 }] }

      described_class.dump(data)

      expect(data[:error].encoding).to eq(Encoding::BINARY)
      expect(data[:nested].first[:params].encoding).to eq(Encoding::UTF_8)
      expect(data[:nested].first[:params]).not_to be_valid_encoding
    end
  end

  describe '.normalize' do
    it 'stringifies keys and keeps the last value for colliding keys' do
      expect(described_class.normalize(:status => 200, 'status' => 'ok', 1 => 'one'))
        .to eq('status' => 'ok', '1' => 'one')
    end

    it 'normalizes strings inside nested hashes and arrays' do
      normalized = described_class.normalize(outer: { inner: [binary_utf8, invalid_binary] })

      expect(normalized).to eq('outer' => { 'inner' => ['不正な値です。', "abc#{replacement * 2}def"] })
      expect(normalized['outer']['inner']).to all(have_attributes(encoding: Encoding::UTF_8))
    end

    it 'normalizes keys' do
      expect(described_class.normalize(binary_utf8 => 1)).to eq('不正な値です。' => 1)
    end

    it 'transcodes strings in other encodings to UTF-8' do
      normalized = described_class.normalize('日本語'.encode(Encoding::Shift_JIS))

      expect(normalized).to eq('日本語')
      expect(normalized.encoding).to eq(Encoding::UTF_8)
    end

    it 'replaces bytes that are invalid in a non UTF-8 encoding' do
      expect(described_class.normalize("abc\xFF".dup.force_encoding(Encoding::US_ASCII))).to eq("abc#{replacement}")
    end

    it 'keeps objects that can be serialized on their own' do
      time = Time.at(0).utc
      expect(described_class.normalize(time)).to equal(time)
    end

    it 'converts symbols to strings' do
      expect(described_class.normalize(%i[a b])).to eq(%w[a b])
    end

    it 'returns valid UTF-8 strings unchanged' do
      string = 'valid'
      expect(described_class.normalize(string)).to equal(string)
    end

    it 'returns numbers, booleans and nil unchanged' do
      expect(described_class.normalize([1, 1.5, nil, true, false])).to eq([1, 1.5, nil, true, false])
    end
  end
end
