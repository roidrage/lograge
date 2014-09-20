require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::KeyValue do
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

  it "includes the 'controller' key/value" do
    expect(subject).to include('controller=welcome')
  end

  it "includes the 'action' key/value" do
    expect(subject).to include('action=index')
  end

  it_behaves_like 'a key value formatter'
end
