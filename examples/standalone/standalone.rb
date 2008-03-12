$:.unshift '/Users/Jed/Development/Libraries/swxruby/lib'
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
Merb::Router.prepare { |r| r.match('/').to(:controller => 'swx_ruby', :action =>'gateway') }

class SwxRuby < Merb::Controller
  def gateway
    send_data(SwxGateway.process(params), :filename => 'data.swf', :type => 'application/swf')
  end
end