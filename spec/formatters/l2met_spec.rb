require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::L2met do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'admin/welcome',
      action: 'index',
      db: 20.00,
      view: 10.00, 
      duration: 30.00,
      cache: 40.00
    }
  end

  it_behaves_like "a key value formatter"

  subject { described_class.new.call(payload) }

  it { should include('source=admin/welcome#index') }
  it { should_not include('controller=admin/welcome') }
  it { should_not include('action=index') }
  it { should include('measure#page.duration=30.00') }
  it { should include('measure#page.view=10.00') }
  it { should include('measure#page.db=20.00') }
  it { should include('measure#page.cache=40.00') }
end
