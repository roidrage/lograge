require "lograge/version"
require 'active_support/core_ext/module/attribute_accessors'

module Lograge
  mattr_accessor :logger  
end

require 'lograge/railtie' if defined? Rails::Railtie
