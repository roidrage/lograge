require 'spec_helper'
require 'lograge'

describe Lograge::Formatters::Cee do
  it "prepends the output with @cee" do
    expect(subject.call({})).to match(/^@cee/)
  end

  it "serializes custom attributes" do
    expect(subject.call(custom: 'data')).to match('{"custom":"data"}')
  end
end
