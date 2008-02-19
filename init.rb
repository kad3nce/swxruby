begin
  require 'rubygems'
  require 'swxruby'
rescue
  # If the swxruby gem isn't installed, assume this plugin installation is
  # running from a checkout of trunk and fail silently.
end
require 'swx_gateway'
require 'yaml'

# Tell SwxGateway where app root and config file are located
SwxGateway.app_root = RAILS_ROOT
SwxGateway.swx_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'swx.yml'))

# Load the service classes
SwxGateway.init_service_classes

# Initialize Rails controller integration (render :swx  => 'my data')
require 'rails_integration/render_decorator'

# Register the SWX mime tytpe
Mime::Type.register "application/swf", :swx