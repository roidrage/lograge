# frozen_string_literal: true

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

  it_behaves_like 'a key value formatter'

  subject { described_class.new.call(payload) }

  it "includes the 'source' key/value" do
    expect(subject).to include('source=admin-welcome:index')
  end

  it "does not include the 'controller' key/value" do
    expect(subject).not_to include('controller=admin/welcome')
  end

  it "does not include the 'action' key/value" do
    expect(subject).not_to include('action=index')
  end

  it "includes the 'page.duration'" do
    expect(subject).to include('measure#page.duration=30.00')
  end

  it "includes the 'page.view'" do
    expect(subject).to include('measure#page.view=10.00')
  end

  it "includes the 'page.db'" do
    expect(subject).to include('measure#page.db=20.00')
  end

  it "includes the 'page.cache'" do
    expect(subject).to include('measure#page.cache=40.00')
  end
end
