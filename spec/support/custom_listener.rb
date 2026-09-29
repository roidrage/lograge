# frozen_string_literal: true

class CustomListener
  attr_reader :events

  def initialize
    @events = []
  end

  def call(*args)
    @events << args
  end
end
