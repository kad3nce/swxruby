class SwxController < ApplicationController
  protect_from_forgery :except => 'gateway'
  
  def gateway
    # request handler takes in the params hash 
		send_data(SwxGateway.process(params), :type => 'application/swf', :filename => 'data.swf', :disposition => 'inline')
  end
end
