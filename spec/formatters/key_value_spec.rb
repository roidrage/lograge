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

  it { should include('method=GET') }
  it { should include('path=/') }
  it { should include('controller=welcome') }
  it { should include('action=index') }
  it { should include('status=200') }
  it { should include('custom=data') }
end