# Taken from Railties
def gsub_file(relative_destination, regexp, *args, &block)
  path = relative_destination
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

SWX_RUBY_ROOT ||= File.expand_path(File.dirname(__FILE__))
readme = IO.readlines(File.join(SWX_RUBY_ROOT, 'README'))
@rails_usage = readme.slice(readme.index("=== Rails Plugin Usage\n")..-1)

begin
  require 'fileutils'
	include FileUtils
  
	# Copy config file
  unless File.exist?("#{RAILS_ROOT}/config/swx.yml")
		puts '*** Copying config file to config/swx.yml ***'
    cp(File.join(SWX_RUBY_ROOT, 'lib', 'swxruby', 'rails_integration', 'swx.yml'), "#{RAILS_ROOT}/config/swx.yml")
  end

	# Copy SWX controller
	unless File.exist?("#{RAILS_ROOT}/app/controllers/swx_controller.rb")
		puts '*** Copying SWX controller to app/controllers/swx_controller.rb ***'
	  cp(File.join(SWX_RUBY_ROOT, 'lib', 'swxruby', 'rails_integration', 'swx_controller.rb'), "#{RAILS_ROOT}/app/controllers/swx_controller.rb")
	end
	
	# Create services directory
	unless File.exist?("#{RAILS_ROOT}/app/services")
		puts '*** Creating services directory at app/services ***'
		mkdir("#{RAILS_ROOT}/app/services")
	end

	unless ESSENTIALS
  	# Copy TestDataTypes class to app/services
  	unless File.exist?("#{RAILS_ROOT}/app/services/test_data_types.rb")
  		puts '*** Copying TestDataTypes service class to app/services ***'
  		cp(File.join(SWX_RUBY_ROOT, 'lib', 'swxruby', 'services', 'test_data_types.rb'), "#{RAILS_ROOT}/app/services/test_data_types.rb")
  	end
	
  	# Copy HelloWorld class to app/services
  	unless File.exist?("#{RAILS_ROOT}/app/services/hello_world.rb")
  		puts '*** Copying HelloWorld service class to app/services ***'
  		cp(File.join(SWX_RUBY_ROOT, 'lib', 'swxruby', 'services', 'hello_world.rb'), "#{RAILS_ROOT}/app/services/hello_world.rb")
  	end
	end
	
	# Add route for SWX gateway to routes.rb
	puts '*** Adding route for SWX gateway to routes.rb ***'
	sentinel = 'ActionController::Routing::Routes.draw do |map|'
	gsub_file "#{RAILS_ROOT}/config/routes.rb", /(#{Regexp.escape(sentinel)})/mi do |match|
	  "#{match}\n  map.swx '/swx', :controller => 'swx', :action => 'gateway'\n"
	end

	# Check for installation of JSON gem
	print '*** Checking if JSON gem is installed'
	require 'rubygems'
	require 'json'
	puts ': JSON gem detected ***'
	
	puts @rails_usage
rescue LoadError
	puts @rails_usage
	
	puts '!!!!! You do not have the JSON gem installed. SWX Ruby will not function without it.'
	puts '!!!!! Please "gem install json" to get the JSON gem, then SWX Ruby should be ready to roll.'
rescue Exception => e
  puts 'ERROR INSTALLING SWX Ruby: ' + e.message
end