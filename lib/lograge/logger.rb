require 'active_support/tagged_logging'

class Lograge::Logger < ActiveSupport::TaggedLogging
  def add(severity, message = nil, progname = nil, &block)
    message = (block_given? ? block.call : progname) if message.nil?
    @logger.add(severity, "#{message} #{tags_as_pairs}", progname)
  end

  def tags_as_pairs
    tags = current_tags
    if tags.any?
      tags.collect {|tag| tag}.join(" ")
    end
  end
end
