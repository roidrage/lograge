require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Json do
  let(:deserialized_output) { JSON.parse(subject.call(custom: 'data')) }

  it "serializes custom attributes" do
    expect(deserialized_output).to eq('custom' => 'data')
  end
end
