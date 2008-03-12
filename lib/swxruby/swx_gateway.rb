require 'json'
require 'swx_assembler'

# Create a namespace (sandbox) for SWX service classes; ensures we don't get 
# any bored twelve year-olds trying to call Kernel#system using our gateway
# (they would instead be calling SwxServiceClasses::Kernel#system)
module SwxServiceClasses; end

class SwxGateway
  class << self
		attr_accessor :app_root, :swx_config
		
		# Eval all files in the services_path into the SwxServiceClasses namespace
		def init_service_classes
			Dir.glob(File.join(app_root, swx_config['services_path'], './**/*.rb'))	do |filename| 
				# Load service class into SwxServiceClasses namespace. 
				SwxServiceClasses.module_eval(File.read(filename))
			end
			true
		end
		
		# Convert strings containing 'null' to nil. Null in Flash is equivalent to nil in Ruby.
		def nillify_nulls(args_array)
			# Convert all strings containing 'null' to nil
			args_array.collect! { |arg| if arg == 'null' then nil else arg end }
			# Return nil if the args array contained only 'null' strings
			if args_array.compact.empty? then nil else args_array end
		end
		
		# The entry point for SWX request processing. Takes a hash of +params+ and goes to work generating SWX bytecode. 
    # 
		# Special note: Contrary to Ruby convention, keys in the +params+ hash are camelCase (instead of underscored). This 
		# is to maintain compatibility with the SWX AS library which sends request parameters 
		# using camelCase (ActionScript's variable naming convention).
    # 
		# ==== Params
		# * <tt>:args</tt> --  JSON string of arguments (converted to a Ruby object and passed to the specified method of the service class)
		# * <tt>:debug</tt> -- Boolean. If set to true, the generated SWX file will attempt to establish a local connection the SWX Analyzer when opened in Flash Player.
		# * <tt>:method</tt> --  specifies the method to be called on the service class. May be either camelCased or underscored (camelCased will be converted to underscored before being called on the service class)
		# * <tt>:serviceClass</tt> -- specifies the service class 
		# * <tt>:url</tt> -- (optional) the url of the SWF file making this request. Added to the generated SWX file to skirt cross-domain issues. If not specified, the resulting SWX file allow access from any domain
    # 
		# ==== Examples
	  #   SwxGateway.process(:args => 'Hello World!', :debug => true, :method => 'echo_data', :serviceClass => 'Simple', :url => 'http://myfunkysite/swxconsumer.swf')
	  #   # => A binary string of SWX bytecode containing the result of +Simple.new#echo_data('Hello World!')+; debugging enabled and allowing access from the specified url
    #   
	  #   SwxGateway.process(:args => 'Hello World!', :debug => true, :method => 'echo_data', :serviceClass => 'Simple')
	  #   # => Same as previous, except allows access from any url
    #   
	  #   SwxGateway.process(:args => [1,2], :debug => false, :method => 'addNumbers', :serviceClass => 'Simple', :url => 'http://myfunkysite/swxconsumer.swf')
	  #   # calls params[:method].underscore
	  #   # => A binary string of SWX bytecode containing the result of +Simple.new#add_numbers(1, 2)+; no debugging and allowing access from the specified url
    def process(params)
      # Set defaults if the SWX gateway isn't configured
      swx_config ||= {'compression_level' => 4, 'allow_domain' => true}
      
			# convert JSON arguments to a Ruby object
			args = json_to_ruby params[:args]
			
      unless args.nil?
        # Ensure that none of the arguments contain 'undefined'
  			raise ArgumentError, "The request contained undefined args.\n  serviceClass: #{params[:serviceClass]}\n  method: #{params[:method]}\n  args: #{args.join(', ')}" if args.any? { |argument| argument == 'undefined' }
				# Convert 'null' strings in args array to nil
			  args = nillify_nulls(args)
  		end
			
			# Fetch the class constant for the specified service class
			validate_service_class_name(params[:serviceClass])
      service_class = class_eval("SwxServiceClasses::#{params[:serviceClass]}")

			# convert camelCased params[:method] to underscored (does nothing if params[:method] is already underscored)
			# This effectively bridges the gap between ActionScript and Ruby variable/method naming conventions.
			params[:method] = params[:method].underscore

			# Prevent nefarious use of methods that the service class inherited from Object
			raise NoMethodError unless (service_class.public_instance_methods - Object.public_instance_methods).include?(params[:method])
			
      # Instantiate the service class, call the specified method, and capture the response
			service_class_response = if args.nil?
				# No args were passed, so assume the service class' method doesn't take any arguments
	      service_class.new.send(params[:method])
			else
				# Call the service class' method and pass in the arguments (uses an * to pass an array as multiple arguments)
	      service_class.new.send(params[:method], *args)
			end

      # convert 'true' and 'false' to real booleans
      debug_param = params[:debug] == 'true' ? true : false
      
      # assemble and return swx file 
			SwxAssembler.write_swf(service_class_response, debug_param, swx_config['compression_level'], params[:url], swx_config['allow_domain'])
    end
    
    def json_to_ruby(arguments) #:nodoc:
      JSON.parse arguments unless arguments.nil? || arguments.empty?
    end

		def validate_service_class_name(service_class) #:nodoc:
			unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ service_class
		    raise NameError, "#{service_class.inspect} is not a valid constant name!"
		  end
		end
  end
end