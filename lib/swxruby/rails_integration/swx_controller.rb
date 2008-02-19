class SwxController < ApplicationController
  def gateway
    # request handler takes in the params hash 
		send_data(SwxGateway.process(params), :type => 'application/swf', :filename => 'data.swf')
  end
end
