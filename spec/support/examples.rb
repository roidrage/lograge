# frozen_string_literal: true

shared_examples_for 'a key value formatter' do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'welcome',
      action: 'index',
      custom_sentence: 'Hello world',
      custom_sentence_with_quotes: "I'm a \"test value\""
    }
  end

  subject { described_class.new.call(payload) }

  it "includes the 'method' key/value" do
    expect(subject).to include('method=GET')
  end

  it "includes the 'path' key/value" do
    expect(subject).to include('path=/')
  end

  it "includes the 'status' key/value" do
    expect(subject).to include('status=200')
  end

  it "includes the 'custom' key/value" do
    expect(subject).to include('custom=data')
  end

  it "includes the 'custom_sentence' key/value" do
    expect(subject).to include('custom_sentence="Hello world"')
  end

  it "includes the 'custom_sentence_with_quotes' key/value" do
    expect(subject).to include('custom_sentence_with_quotes="I\'m a \"test value\"')
  end
end
