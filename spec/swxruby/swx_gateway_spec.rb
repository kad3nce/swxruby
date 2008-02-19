require File.dirname(__FILE__) + '/../spec_helper'
require 'swx_gateway'


module SwxGatewaySpecHelper
	def configure_swx_gateway
		SwxGateway.app_root = './'
		SwxGateway.swx_config = {
			'services_path' 		 => File.join('./', 'lib', 'swxruby', 'services'), 
			'allow_domain' 		 => true, 
			'compression_level' => 4
		}
	end
end

describe 'SwxGateway#init_service_class' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
		SwxGateway.init_service_classes
	end
	
	it 'should initialize the classes within the SwxServiceClasses namespace' do
	  lambda { SwxServiceClasses::HelloWorld }.should_not raise_error(NameError)
	end
	
	it 'should not initialize the service classes in the top-level namespace' #do
		#lambda { HelloWorld }.should raise_error(NameError)
	#end
	
	it 'should initialize all of the service classes in the service classes folder' do
		lambda { SwxServiceClasses::HelloWorld }.should_not raise_error(NameError)
		lambda { SwxServiceClasses::TestDataTypes }.should_not raise_error(NameError)
	end
end

describe 'SwxGateway#json_to_ruby' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
	end
	
  it 'should convert a JSON string to a native Ruby object' do
    SwxGateway.json_to_ruby(%q([1,2,{"a":3.141},false,true,null,"4..10"])).should == [1, 2, {"a"=>3.141}, false, true, nil, "4..10"]
  end
end

describe 'SwxGateway#nillify_nulls' do
  it 'should convert "null" to nil' do
    SwxGateway.nillify_nulls([1, 'null', 'a string', 'another string', 'null']).should == [1, nil, 'a string', 'another string', nil]
  end

	it 'should return nil if the args array only contains nil values' do
	  SwxGateway.nillify_nulls(['null']).should == nil
	end
end

describe 'SwxGateway#process' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
	
		mock(SwxServiceClasses)
	end
	
	it 'should process a hash of params with no args param and call SwxAssembler#write_swf with them' do
		hello_world = mock(SwxServiceClasses::HelloWorld)
		
		hello_world.should_receive(:send).with('just_say_the_words').and_return('Hello World!')
		SwxServiceClasses::HelloWorld.should_receive(:new).and_return(hello_world)
		
		SwxAssembler.should_receive(:write_swf).with('Hello World!', nil, 4, nil, true)
		
	  SwxGateway.process(:serviceClass => 'HelloWorld', :method => 'justSayTheWords')
	end
	
	it 'should process a hash of params with an args param containing only "[null]" and call SwxAssembler#write_swf with them' do
		hello_world = mock(SwxServiceClasses::HelloWorld)
		
		hello_world.should_receive(:send).with('just_say_the_words').and_return('Hello World!')
		SwxServiceClasses::HelloWorld.should_receive(:new).and_return(hello_world)
		
		SwxAssembler.should_receive(:write_swf).with('Hello World!', nil, 4, nil, true)
		
	  SwxGateway.process(:serviceClass => 'HelloWorld', :method => 'justSayTheWords', :args => '[null]')
	end
	
	
	it 'should process a hash of params with an args param containing only "[]" and call SwxAssembler#write_swf with them' do
		hello_world = mock(SwxServiceClasses::HelloWorld)
		
		hello_world.should_receive(:send).with('just_say_the_words').and_return('Hello World!')
		SwxServiceClasses::HelloWorld.should_receive(:new).and_return(hello_world)
		
		SwxAssembler.should_receive(:write_swf).with('Hello World!', nil, 4, nil, true)
		
	  SwxGateway.process(:serviceClass => 'HelloWorld', :method => 'justSayTheWords', :args => '[null]')
	end
	
	it 'should process a hash of params with an args param and call SwxAssembler#write_swf with them' do
	  arithmetic = mock(SwxServiceClasses::Arithmetic)
		arithmetic.should_receive(:send).with('addition', 1, 2).and_return(3)
		SwxServiceClasses::Arithmetic.should_receive(:new).and_return(arithmetic)
		
		SwxAssembler.should_receive(:write_swf).with(3, nil, 4, nil, true)
		
		SwxGateway.process(:serviceClass  => 'Arithmetic', :method  => 'addition', :args => '[1, 2]')
	end
	
	it 'should convert a "true" string in the debug param to a boolean'
	
	it 'should convert a "false" string in the debug param to a boolean'
	
	it 'should raise a NoMethodError when attempting to call methods that the service class inherited from Object' do
		lambda { SwxGateway.process(:serviceClass  => 'TestDataTypes', :method  => 'instance_eval', :args => '["@foo"]') }.should raise_error(NoMethodError)
	end
	
	it 'should raise an ArgumentError if any of the arguments in params[:args] equal "undefined"' do
		lambda { SwxGateway.process(:serviceClass  => 'MyNiftyClass', :method  => 'method_requiring_args', :args => '["undefined"]') }.should raise_error(ArgumentError)
	end
	
	it 'should convert "null" strings in the args param to nil before calling SwxAssembler#write_swf' do
	  arithmetic = mock(SwxServiceClasses::Arithmetic)
		arithmetic.should_receive(:send).with('addition', 1, nil).and_return(3)
		SwxServiceClasses::Arithmetic.should_receive(:new).and_return(arithmetic)
		
		SwxAssembler.should_receive(:write_swf).with(3, nil, 4, nil, true)
		
		SwxGateway.process(:serviceClass  => 'Arithmetic', :method  => 'addition', :args => '[1, "null"]')
	  
	end
	
	it 'should raise a NameError when passed an invalid constant name as a service class' do
	  lambda { SwxGateway.process(:serviceClass  => 'arithmetic', :method  => 'addition', :args => '[1, 2]') }.should raise_error(NameError)
	end
end

describe 'SwxGateway#validate_service_class_name' do
	it 'should raise a NameError when passed an invalid constant name' do
	  lambda { SwxGateway.validate_service_class_name('invalid name') }.should raise_error(NameError)
	end
	
	it 'should not raise an error when passed a valid constant name' do
	  lambda { SwxGateway.validate_service_class_name('ValidConstantName') }.should_not raise_error
	end
end