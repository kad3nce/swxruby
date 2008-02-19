class TestTO
	def initialize
		@prop1 = 'A string'
		@prop2 = 42
	end
end

###
 # Data type test service. Run the TestDataTypes.fla to run through all these tests using SWX RPC. 
 #
 # @package default
 # @author Aral Balkan
 ###
class TestDataTypes
	###
	 # Returns the boolean true.
	 # @author Aral Balkan
	 ###
	def test_true
		true
	end
	
	###
	 # Returns the boolean false.
	 # @author Aral Balkan
	 ###
	def test_false
		false
	end
	
	###
	 # Returns the array ['It', 'works']
	 # @author Aral Balkan
	 ###
	def test_array
		%w(It works)
	end
	
	###
	 # Returns the nested array ['It', ['also'], 'works]
	 # @author Aral Balkan
	 ###
	def test_nested_array
		['It', ['also'], 'works']
	end
	
	###
	 # Returns the integer 42.
	 # @author Aral Balkan
	 ###
	def test_integer
		42
	end
	
	###
	 # Returns the float 42.12345.
	 # @author Aral Balkan
	 ###
	def test_float
		42.12345
	end
	
	###
	 # Returns the string "It works!"
	 # @author Aral Balkan
	 ###
	def test_string
		"It works!"
	end
	
	###
	 # Returns the associative array ['it' => 'works', 'number' => 42]
	 # @author Aral Balkan
	 ###
	def test_associative_array
		{'it' => 'works', 'number' => 42}
	end

	###
	 # Returns an instance of the TestTO class with properties prop1: "A string" and prop2: 42.
	 # @author Aral Balkan
	 ###
	def test_object
		TestTO.new
	end
	
	###
	 # Returns null.
	 # @author Aral Balkan
	 ###
	def test_null
		nil
	end
end