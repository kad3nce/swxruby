require 'bytecode_converter'
require 'helper_module'
require 'uri/common.rb'
require 'zlib'

class SwxAssembler
	include HelperMethods
	
	# Header - FCS (uncompressed), version Flash 6
	UNCOMPRESSED_SWF = '46'
	COMPRESSED_SWF = '43'
	HEADER = '575306LLLLLLLL300A00A0000101004302FFFFFF'

	# Misc
	NULL_TERMINATOR = '00'

	# Allow domain (*)
	ALLOW_DOMAIN = '960900005F706172656E74001C960600005F75726C004E960D0007010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217'
	SYSTEM_ALLOW_DOMAIN = '07010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217'

	# Debug SWX bytecode. Creates a local connection to the SWX Debugger front-end.)
	DEBUG_START = '883C000700726573756C74006C63004C6F63616C436F6E6E656374696F6E005F737778446562756767657200636F6E6E6563740064656275670073656E6400'
	DEBUG_END = '960D0008010600000000000000000802403C9609000803070100000008011C9602000804521796020008001C960500070100000042960B0008050803070300000008011C96020008065217'
	
	class << self
		def allow_domain_bytecode(allow_domain_url = '')
  		if (allow_domain_url.nil? || allow_domain_url.empty?)
  			# No URL passed -- possibly called by legacy code, use the old _parent._url version.
        # error_log('[SWX] INFO: No URL passed from client. Defaulting to old behavior. You must call System.security.allowDomain on the dataHolder for cross domain data loading to work.');
  			ALLOW_DOMAIN
		  else
				# Firefox/Flash (at least, and tested only on a Mac), sends 
				# file:/// (three slashses) in the URI and that fails the validation
				# so replacing that with two slashes instead.
				allow_domain_url.gsub!('///', '//')
    		# URL is passed, write that into the returned code
    		allow_domain_bytecode = BytecodeConverter.convert(URI.unescape(allow_domain_url))
				
    		# The -13 is to accomodate the other elements being pushed to the 
    		# stack in the hard-coded part of the bytecode.
    		allow_domain_bytecode_length_dec = allow_domain_bytecode.length/2 + 13

    		allow_domain_bytecode_length = integer_to_hexadecimal(allow_domain_bytecode_length_dec, 2);
    		allow_domain_bytecode = '96' + allow_domain_bytecode_length + allow_domain_bytecode + SYSTEM_ALLOW_DOMAIN;
				allow_domain_bytecode
  		end
  	end

	  def compress_swx_file(swx_file, compression_level)
	    # The first eight bytes of a compressed SWF file are left uncompressed
      swx_file.slice!(0...8) + Zlib::Deflate.deflate(swx_file, compression_level)
	  end
	
		def generate_data_bytecode(data)
			data_bytecode = []
			
			# Add a flag to the beginning of the bytecode that tells Flash we're setting a variable (result)
			data_bytecode.push ActionCodes::SET_VARIABLE
						
			# Convert the data (payload) to bytecode
			data_bytecode.push BytecodeConverter.convert(data)
			
			# Generate a push tag if the data was not an Array or a Hash
			data_bytecode.push generate_push_statement(data_bytecode) unless data.is_a?(Array) || data.is_a?(Hash)
			
			# Add the 'result' variable name -- either
			# using the constant table if in debug mode
			# or as a regular string otherwise
      if @debug
				data_bytecode.push '9602000800'
			else
				data_bytecode.push '96080000726573756C7400'
			end
			
			# (SWF bytecode is stored in reverse, so we reverse it here)
      data_bytecode.reverse.join
		end
	  
	  def generate_swx_bytecode(data)
	    # Create the DoAction tag
			do_action_block = []
			
			# Wrap the data bytecode in debug flags if debugging is turned on
			do_action_block.push DEBUG_START if @debug
			
			# Generate bytecode for the data (payload)
			do_action_block.push generate_data_bytecode(data)
      
			# Allow domain? If so add allow domain statement to the SWF
      if (@allow_domain)
        do_action_block.push allow_domain_bytecode(@allow_domain_url)
      end
			
			# Wrap the data bytecode in debug flags if debugging is turned on
			do_action_block.push DEBUG_END if @debug

      # Calculate the size of the do_action block
			do_action_block_size_in_bytes = string_length_in_bytes_hex(do_action_block.join, 4)
			# Add the appropriate flags to the do_action block and concat the finished do_action block into a string
			do_action_block_string = ActionCodes::DO_ACTION + do_action_block_size_in_bytes + do_action_block.join

			# Create the rest of the SWF
			header_type = if @compression_level > 0 then COMPRESSED_SWF else UNCOMPRESSED_SWF end

			swf = header_type + HEADER + do_action_block_string + ActionCodes::SHOW_FRAME + ActionCodes::END_SWF
			swf_size_in_bytes = string_length_in_bytes_hex(swf, 4)
           
			# Replace length placeholder (from HEADER constant) with actual bytecode length
			swf.sub('LLLLLLLL', swf_size_in_bytes)
	  end
	  
		def write_swf(data, debug=false, compression_level=4, allow_domain_url='', allow_domain=true)
		  # Set up SwfAssembler state
		  @debug = debug
		  @compression_level = compression_level
		  @allow_domain_url = allow_domain_url
			@allow_domain = allow_domain

      swx_bytecode = generate_swx_bytecode(data)

			# Convert the bytecode string to ASCII file format
      swx_file = swx_bytecode.hex_to_ascii

      # Compress the file if compression is turned on
      swx_file = compress_swx_file(swx_file, compression_level) if compression_level > 0

      # ====================================
      # = TODO: Remove this before release =
      # ====================================
      # Write the file (for manual 'loadMovie' testing in Flash)
      # File.open('/Users/Jed/Development/Libraries/rSWX/testing/flash/rswx_data.swx', 'w+') do |file|
      #   file << swx_file
      # end      

      swx_file
		end
	end
end