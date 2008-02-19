require 'core_extensions'
require 'date'
require 'helper_module'

class BytecodeConverter
	include HelperMethods
  class << self
	  NULL_TERMINATOR = '00'
	
	  def convert(data)
	    begin
  	    send("#{data.class.to_s.downcase}_to_bytecode", data)
	    rescue NoMethodError
				# Convert the object to a hash of its instance variables 
				object_hash = data.instance_values
				
				if object_hash.empty?	
					raise StandardError, "#{data.class} is an unhandled data type."
				else
		      hash_to_bytecode(object_hash)
				end
	    end
	  end
	
	  protected
		# ================================
		# = Data Type Conversion Methods =
		# ================================
		def complex_data_structure_to_bytecode(data) #:nodoc#
			bytecode = []
			
			# Keeps track of bytecode when recursing into nested data structures
			stack = []

			# Add the bytecode to initialize the data structure
			bytecode.push(if data.is_a?(Array) then ActionCodes::INIT_ARRAY else ActionCodes::INIT_OBJECT end)

			# Add the length of the data structure to the bytecode
			bytecode.push integer_to_bytecode(data.length)
			
			# Convert each element in the data structure to bytecode
			data.each do |element|
				
				# If we're iterating over a hash, then split the element's key/value
				if (data.is_a?(Hash))
					value = element[1]
					element = element[0]
				end

				# ===========================================================
				# = TODO: Remove ActiveRecord::Base check from if statement =
				# ===========================================================

				# Create a push of the current bytecode, if
					 # recursing into a complex data structure
					 #									 							# or
				if (element.is_a?(Array) 							|| 
					    value.is_a?(Array)						  || 
						element.is_a?(Hash)  							|| 
						  value.is_a?(Hash)	 							|| 
						element.is_a?(ActiveRecord::Base) || # we're approaching the 65535 byte limit that can be stored in a single push.
						  value.is_a?(ActiveRecord::Base) || calculate_bytecode_length(bytecode) > 65518)

					# If we haven't written any bytecode into the local
					# buffer yet (if it's empty), or all the data is already pushed, skip writing the push statement
					bytecode.push generate_push_statement(bytecode) unless bytecode.empty? || bytecode.last.begins_with?('96')
					
					# Store current instruction on the stack (SWF bytecode is stored in reverse, so we reverse it here)
					stack.push bytecode.reverse.join
					
					# Reset the bytecode
					bytecode = []
				end
				
				# value will only be populated if we're iterating over a hash
				bytecode.push convert(value) if data.is_a?(Hash)
				
				# element will always contain something (whether iterating over a hash or an array)
				bytecode.push convert(element)
			end

      # If we haven't written any bytecode into the local
			# buffer yet (if it's empty), or all the data is already pushed, skip writing the push statement
      bytecode.push generate_push_statement(bytecode) unless bytecode.empty? || bytecode.last.begins_with?('96')
			
			# Add the bytecode to the local stack variable (SWF bytecode is stored in reverse, so we reverse it here)
			stack.push bytecode.reverse.join
			
			# Join the stack array into a string and return it (SWF bytecode is stored in reverse, so we reverse it here)
			stack.reverse.join
		end
	  alias array_to_bytecode complex_data_structure_to_bytecode 
	  alias hash_to_bytecode complex_data_structure_to_bytecode
	  
    def date_to_bytecode(date) #:nodoc#
      # Format: 2006-09-14
      string_to_bytecode(date.strftime('%Y-%m-%d'))
    end
  
    def datetime_to_bytecode(datetime) #:nodoc#
      # Format: 2006-09-14 02:21:10
			string_to_bytecode(datetime.strftime('%Y-%m-%d %I:%M:%S'))
    end
  
    def falseclass_to_bytecode(*args) #:nodoc#
      DataTypeCodes::BOOLEAN + '00'
    end
  
		def float_to_bytecode(float) #:nodoc#
			hex = []
			[float].pack('E').each_byte { |byte| hex << '%02X' % byte }
															# Aral did this in SWX PHP, so I'm doing it here
			DataTypeCodes::FLOAT + (hex[4..-1] + hex[0..3]).join
		end
	
		def integer_to_bytecode(integer) #:nodoc#
			DataTypeCodes::INTEGER + integer_to_hexadecimal(integer, 4)
		end
		alias bignum_to_bytecode integer_to_bytecode
		alias fixnum_to_bytecode integer_to_bytecode
				
		def nilclass_to_bytecode(*args) #:nodoc#
		  '02'
		end
		
		def string_to_bytecode(string) #:nodoc#
	    DataTypeCodes::STRING + string.unpack('H*').to_s.upcase + NULL_TERMINATOR
	  end
	  
	  def trueclass_to_bytecode(*args) #:nodoc#
      DataTypeCodes::BOOLEAN + '01'
	  end
	end
end