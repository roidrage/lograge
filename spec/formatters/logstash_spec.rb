require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Logstash do
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
  it { should match(/"@source":"unknown"/) }
  it { should match(/"@tags":\[\]/) }
  it { should match(/"@fields":{/) }
  it { should match(/"custom":"data"/) }
  it { should match(/"status":200/) }
  it { should match(/"method":"GET"/) }
  it { should match(/"path":"\/"/) }
  it { should match(/"controller":"welcome"/) }
  it { should match(/"action":"index"/) }
end