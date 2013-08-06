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
  it { expect(subject[:_custom]).to eq('data') }
  it { expect(subject[:short_message]).to eq('[200] GET / (welcome#index)') }
end