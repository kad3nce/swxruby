require File.dirname(__FILE__) + '/../spec_helper'

require 'swx_assembler'

describe SwxAssembler do
  it 'should assemble a swx file without debugging and without compression' do
		BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
    SwxAssembler.write_swf(1, false, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_no_compression.swx'))
  end
  
  it 'should assemble a swx file with debugging and without compression' do
		BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
    SwxAssembler.write_swf(1, true, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_no_compression.swx'))
  end
  
	it 'should assemble a swx file without debugging, without compression, and with an arbitrary "allow domain" url' do
		BytecodeConverter.should_receive(:convert).with('file://Macintosh HD/Users/Jed/Development/Libraries/rSWX/testing/flash/data_testing.swf').once.and_return('0066696C653A2F2F4D6163696E746F73682048442F55736572732F4A65642F446576656C6F706D656E742F4C69627261726965732F725357582F74657374696E672F666C6173682F646174615F74657374696E672E73776600')
		BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
	  SwxAssembler.write_swf(1, false, 0, 'file:///Macintosh HD/Users/Jed/Development/Libraries/rSWX/testing/flash/data_testing.swf').should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_no_compression_arbitrary_allow_domain.swx'))
	end

  it 'should assemble a swx file without debugging and with compression' do
		BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
		SwxAssembler.write_swf(1, false, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_compression_4.swx'))
	end
    
  it 'should assemble a swx file with debugging and with compression' do
		BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
		SwxAssembler.write_swf(1, true, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_compression_4.swx'))
	end
end

describe 'SwxAssembler#allow_domain_bytecode' do
  it 'should generate bytecode to allow an arbitrary url when a url is passed' do
    SwxAssembler.allow_domain_bytecode('file://Macintosh HD/Users/Jed/Development/Libraries/rSWX/testing/flash/data_testing.swf').should == '9666000066696C653A2F2F4D6163696E746F73682048442F55736572732F4A65642F446576656C6F706D656E742F4C69627261726965732F725357582F74657374696E672F666C6173682F646174615F74657374696E672E7377660007010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217'
  end

	it 'should return bytecode to allow all domains if no url is passed' do
	  SwxAssembler.allow_domain_bytecode.should == '960900005F706172656E74001C960600005F75726C004E960D0007010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217'
	end
end

require 'zlib'

describe 'SwxAssembler#compress_swx_file' do
  it 'should remove the first eight bytes of the string before compressing' do
		@swx_file = '123456789'
		@swx_file.should_receive(:slice!).with(0...8).and_return('12345678')
    SwxAssembler.compress_swx_file(@swx_file, 4)
  end

	it 'should compress the remainder of the string using Zlib' do
		@swx_file = '123456789'
		Zlib::Deflate.should_receive(:deflate).with(@swx_file[8..-1], 4).and_return('a compressed string')
		SwxAssembler.compress_swx_file(@swx_file, 4)
	end
end



