require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Graylog2 do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'welcome',
      action: 'index'
    }
  end

  subject { described_class.new.call(payload) }

  it "provides the ':_custom' attribute" do
    expect(subject[:_custom]).to eq('data')
  end

  it "provides the serialized ':short_message' attribute" do
    expect(subject[:short_message]).to eq('[200] GET / (welcome#index)')
  end
end
