# frozen_string_literal: true

require 'delegate'

module Lograge
  class SilentLogger < SimpleDelegator
    %i[debug info warn error fatal unknown].each do |method_name|
      define_method(method_name) { |*_args| }
    end
  end
end
