# frozen_string_literal: true

describe Lograge::Formatters::Lines do
  it 'can serialize custom data' do
    expect(subject.call(custom: 'data')).to eq('custom=data')
  end
end
