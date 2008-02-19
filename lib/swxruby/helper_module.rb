require 'core_extensions'

module DataTypeCodes
   BOOLEAN = '05'
   FLOAT   = '06'
   INTEGER = '07'
   NULL    = '02'
   STRING  = '00'
end

module ActionCodes
	DO_ACTION = '3F03'
	END_SWF = '0000'
	INIT_ARRAY = '42'
	INIT_OBJECT = '43'
	PUSH = '96LLLL'
	SET_VARIABLE = '1D'  # 00
	SHOW_FRAME = '4000'
end

module HelperMethods
	module ClassMethods
		def calculate_bytecode_length(bytecode)
			# Calculate bytecode length *without* counting the init array or init object action
			bytecode.join.sub(/^(#{ActionCodes::INIT_ARRAY}|#{ActionCodes::INIT_OBJECT})/, '').length/2
		end

		def generate_push_statement(bytecode)
			unpushed_data = []
			# Iterate over the bytecode array in reverse and add all of the unpushed
			# data to 'unpushed_data'
			bytecode.reverse_each do |bytecode_chunk|
				if bytecode_chunk.begins_with?('96') || bytecode_chunk.begins_with?('1D') then break else unpushed_data << bytecode_chunk end
			end
			
			# Since we iterated over the bytecode in reverse, unpushed_data is reversed, so 
			# reverse it again before passing it into #calculate_bytecode_length
			bytecode_length = calculate_bytecode_length(unpushed_data.reverse)
			
			 # TODO: Replace with constant
			'96' + integer_to_hexadecimal(bytecode_length, 2)
		end
		
		def integer_to_hexadecimal(integer, number_of_bytes=1)
			make_little_endian("%0#{number_of_bytes*2}X" % integer)
		end

		def make_little_endian(hex_string)
			# split into an array of string pairs
			# reverse the array and join back into a string
			pad_string_to_byte_boundary(hex_string).scan(/../).reverse.join
		end

		def pad_string_to_byte_boundary(hex_string)
			hex_string += '0' if hex_string.length % 2 == 1
			hex_string
		end
		
		# Returns a string with the length of the passed hex string in bytes
		# padded to display in 'number_of_bytes' bytes.
		def string_length_in_bytes_hex(string, number_of_bytes)
																										 # Divide length in chars by 2 to get length in bytes
			bytecode_length_in_hex = integer_to_hexadecimal(string.length/2, number_of_bytes)
		end
	end
	
	extend ClassMethods
	
	def self.included(receiver)
		receiver.extend(ClassMethods)
	end
end