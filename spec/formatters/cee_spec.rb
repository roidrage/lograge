# frozen_string_literal: true

describe Lograge::Formatters::Cee do
  it 'prepends the output with @cee' do
    expect(subject.call({})).to match(/^@cee/)
  end

  it 'serializes custom attributes' do
    expect(subject.call(custom: 'data')).to match('{"custom":"data"}')
  end

  it 'serializes non-ASCII binary strings instead of raising' do
    expect(subject.call(error: '不正な値です。'.b)).to eq('@cee: {"error":"不正な値です。"}')
  end
end
