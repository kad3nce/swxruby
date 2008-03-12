require 'swx_assembler'
require 'swx_gateway'

ActionController::Base.class_eval do
	def render_with_swx(*args, &block)
	  options = args.first
		if options.is_a?(Hash) && options.keys.include?(:swx)
			swf_bytecode = SwxAssembler.write_swf(
								       options[:swx], 
											 params[:debug], 
											 SwxGateway.swx_config['compression_level'], 
											 params[:url], 
											 SwxGateway.swx_config['allow_domain']
										 )
			send_data(swf_bytecode, :type => 'application/swf', :filename => 'data.swf')
		else
			render_without_swx(*args, &block)
		end
	end
	alias_method_chain :render, :swx
end
