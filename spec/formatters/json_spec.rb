# frozen_string_literal: true

describe Lograge::Formatters::Json do
  let(:replacement) { [0xFFFD].pack('U') } # U+FFFD REPLACEMENT CHARACTER
  let(:deserialized_output) { JSON.parse(subject.call(custom: 'data')) }

  it 'serializes custom attributes' do
    expect(deserialized_output).to eq('custom' => 'data')
  end

  it 'serializes non-ASCII binary strings instead of raising' do
    output = subject.call(status: 500, error: "StandardError: #{'不正な値です。'.b}")
    expect(JSON.parse(output)).to eq('status' => 500, 'error' => 'StandardError: 不正な値です。')
  end

  it 'serializes invalid UTF-8 strings instead of raising' do
    output = subject.call(params: { 'email' => "\xFF@example.com".dup.force_encoding(Encoding::UTF_8) })
    expect(JSON.parse(output)).to eq('params' => { 'email' => "#{replacement}@example.com" })
  end

  it 'serializes keys that collide once stringified instead of raising' do
    expect(JSON.parse(subject.call(:status => 200, 'status' => 'ok'))).to eq('status' => 'ok')
  end
end
