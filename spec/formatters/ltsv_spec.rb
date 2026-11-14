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

  context 'when the error contains hard tabs, newlines or backslashes' do
    let(:payload) do
      {
        status: 500,
        error: "RuntimeError: broke\there\nand here\\"
      }
    end

    it 'escapes them so the record stays a single field-separated line' do
      expect(subject).to eq("status:500\terror:'RuntimeError: broke\\there\\nand here\\\\'")
    end
  end
end
