$:.unshift File.join(File.dirname(__FILE__), '..', 'lib', 'swxruby')
require 'rubygems'
require 'spec/runner'

require 'core_extensions'

class MyClass
	def initialize
		@foo = 'foo'
		@bar = 'bar'
	end
end

describe 'Object extensions' do
  it '#instance_values should convert an object\'s instance variables to a hash' do
    MyClass.new.instance_values.should be_an_instance_of(Hash)
    MyClass.new.instance_values.sort_by { |key, value| value }.should == [['bar', 'bar'], ['foo', 'foo']]
  end
end