# frozen_string_literal: true

describe Lograge::Formatters::Raw do
  it 'serializes custom attributes' do
    expect(subject.call(custom: 'data')).to eq(custom: 'data')
  end
end
