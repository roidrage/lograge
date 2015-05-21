require 'lograge'

describe Lograge::Formatters::Lines do
  it 'can serialize custom data' do
    expect(subject.call(custom: 'data')).to eq('custom=data')
  end
end
