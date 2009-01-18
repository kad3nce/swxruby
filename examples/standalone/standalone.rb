# = Merb Standalone SWX Ruby Server
# 
# An example of how simple it is to build a standalone SWX Ruby server using Merb.
# 
# == Prerequisites
# 
# * SWX Ruby Gem (gem install swxruby)
# * merb-core 0.9.1 or later (gem install merb-core)
# 
# == Take it for a spin
# 
# * Open a terminal in the examples/standalone directory and execute 'merb -I standalone.rb' to fire up the Merb server.
# * Open standalone.fla in Flash 8 or later.
# * Publish Preview (ctrl+enter on Windows; cmd+enter on OS X).
# * Watch as the output panel begins tracing "Hello from Merb!".
require 'rubygems'
require 'swxruby'

# =================
# = Service Class =
# =================
class SwxServiceClasses::HelloMerb
  def just_say_the_words
    'Hello from Merb!'
  end
end

# ====================
# = Merb Application =
# ====================
Merb::Router.prepare { |r| r.match('/').to(:controller => 'swx_ruby_controller', :action =>'gateway') }

class SwxRubyController < Merb::Controller
  def gateway
    send_data(SwxGateway.process(params), :filename => 'data.swf', :type => 'application/swf', :disposition => 'inline')
  end
end