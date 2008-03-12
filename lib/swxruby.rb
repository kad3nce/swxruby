$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), 'swxruby')
class SwxRuby
  VERSION = '0.7'
end
require 'swx_gateway'