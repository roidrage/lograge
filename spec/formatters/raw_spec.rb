require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Raw do
  it { expect( subject.call({ custom: 'data' })).to eq({ custom: 'data' }) }
end