RSPEC_ON_RAILS_FILE = File.expand_path(File.dirname(__FILE__) + "../../../rspec_on_rails/lib/spec/rails.rb")
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "../../../../../")

if File.exist?(RSPEC_ON_RAILS_FILE)
	ENV["RAILS_ENV"] = "test"
	require RAILS_ROOT + "/config/environment"
	require RSPEC_ON_RAILS_FILE

	Spec::Runner.configure do |config|
	  config.use_transactional_fixtures = false
	  config.use_instantiated_fixtures  = false
	  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

	  # You can declare fixtures for each behaviour like this:
	  #   describe "...." do
	  #     fixtures :table_a, :table_b
	  #
	  # Alternatively, if you prefer to declare them only once, you can
	  # do so here, like so ...
	  #
	  #   config.global_fixtures = :table_a, :table_b
	  #
	  # If you declare global fixtures, be aware that they will be declared
	  # for all of your examples, even those that don't use them.
	end
	
	
	$:.unshift File.join(File.dirname(__FILE__), '..', 'lib', 'rails_integration')
	$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
	require 'rubygems'
	require 'spec/runner'

	require 'render_decorator'
	require 'swx_gateway'
	
	describe 'Render decorator\'s effect on Rails\' vanilla render method' do
	  it 'should alias ActionController::Base#render as render_with_swx' do
	    ActionController::Base.new.should respond_to(:render_with_swx)
	  end
	
		it 'should create ActionController::Base#render_without_swx' do
		  ActionController::Base.new.should respond_to(:render_without_swx)
		end
	end
	
	describe '#render_with_swx' do
		before do
			@controller = ActionController::Base.new
		  @controller.stub!(:params).and_return(:debug => 'true', :url => '')
			@controller.stub!(:send_data)
			SwxAssembler.stub!(:write_swf).and_return('swx bytecode')
		end
		
		it 'should delegate calls that don\'t contain a :swx key to #render_without_swx' do
			@controller.should_receive(:render_without_swx)
			@controller.render(:text => 'not a swx request')
		end
		
	  it 'should utilize SwxAssembler to generate the SWX bytecode' do
			SwxAssembler.should_receive(:write_swf).with('Jeremiah was a bullfrog.', 'true', SwxGateway.swx_config['compression_level'], '', SwxGateway.swx_config['allow_domain'])
			@controller.render(:swx => 'Jeremiah was a bullfrog.')
	  end
	
		it 'should stream the generated SWX bytecode back to the user' do
			@controller.should_receive(:send_data).with('swx bytecode', :type => 'application/swf', :filename => 'data.swf', :disposition => 'inline')
			@controller.render(:swx => 'some data')
		end
	end
else
	puts 'Not installed as Rails plugin. Skipping Rails integration specifications.'
end


