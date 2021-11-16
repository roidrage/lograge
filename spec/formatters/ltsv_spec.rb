# frozen_string_literal: true

describe Lograge::Formatters::LTSV do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'welcome',
      action: 'index',
      will_escaped: '\t'
    }
  end

  subject { described_class.new.call(payload) }

  it "includes the 'controller' key:value" do
    expect(subject).to include('controller:welcome')
  end

  it "includes the 'action' key:value" do
    expect(subject).to include('action:index')
  end

  it 'escapes escape sequences as value' do
    expect(subject).to include('will_escaped:\\t')
  end

  it 'is separated by hard tabs' do
    expect(subject.split("\t").count).to eq(payload.count)
  end
end
