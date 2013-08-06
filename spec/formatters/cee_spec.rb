require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Cee do
  it { expect( subject.call({})).to match(/^@cee/) }
  it { expect(subject.call({ custom: 'data'})).to match('{"custom":"data"}') }
end