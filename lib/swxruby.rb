$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), 'swxruby')

puts "
# ====================
# = Loading Swx Ruby =
# ===================="
require 'swx_gateway'
