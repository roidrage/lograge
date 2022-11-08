# frozen_string_literal: true

describe Lograge::Formatters::KeyValueDeep do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'welcome',
      action: 'index',
      params: {
        object: {
          key: 'value',
          key_array: [1, '2', 3.4]
        }
      }
    }
  end

  subject { described_class.new.call(payload) }

  it "includes the 'controller' key/value" do
    expect(subject).to include('controller=welcome')
  end

  it "includes the 'action' key/value" do
    expect(subject).to include('action=index')
  end

  it "includes the 'params_object_key' key/value" do
    expect(subject).to include('params_object_key=value')
  end

  it "includes the 'params_object_key_array_1' key/value" do
    expect(subject).to include('params_object_key_array_1=2')
  end

  it 'returns the correct serialization' do
    expect(subject).to eq("custom=data status=200 method=GET path=/ \
controller=welcome action=index params_object_key=value params_object_key_array_0=1 \
params_object_key_array_1=2 params_object_key_array_2=3.40")
  end

  it_behaves_like 'a key value formatter'
end
