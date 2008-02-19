$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), 'swxruby')

module Swxruby
  puts "
  # ====================
  # = Loading Swx Ruby =
  # ===================="
  require 'swx_gateway'
end