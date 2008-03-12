require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

NAME = 'swxruby'
SWXRUBY_VERSION = '0.7'
SUDO = 'sudo'

# ==============================
# = Packaging and Installation =
# ==============================
CLEAN.include ["**/.*.swf", "pkg", "*.gem", "doc"]

spec = Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = SWXRUBY_VERSION
  s.author       = 'Jed Hurt'
  s.email        = 'jed.hurt@gmail.com'
  s.homepage     = 'http://swxruby.org'
  s.summary      = 'SWX Ruby: The Ruby Implementation of SWX RPC'
  s.bindir       = 'bin'
  s.description  = s.summary
  s.executables  = %w( swxruby )
  s.require_path = 'lib'
  s.files        = %w( LICENSE README Rakefile CHANGELOG init.rb install.rb ) + Dir["{bin,spec,lib,examples}/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README LICENSE CHANGELOG )
  #s.rdoc_options     += RDOC_OPTS + ["--exclude", "^(app|uploads)"]

  # Dependencies
  s.add_dependency "json_pure"
  # Requirements
  s.requirements << "install the json gem to get faster json parsing"
  s.required_ruby_version = ">= 1.8.4"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Run :package and install the resulting .gem'
task :install => :package do
  sh %{#{SUDO} gem install --local pkg/#{NAME}-#{SWXRUBY_VERSION}.gem --no-rdoc --no-ri}
end

desc 'Run :clean and uninstall the .gem'
task :uninstall => :clean do
  sh %{#{SUDO} gem uninstall #{NAME}}
end

# ==================
# = Documentation  =
# ==================
Rake::RDocTask.new(:rdoc) do |rd|    
  rd.main = 'README' # 'name' will be the initial page displayed
  rd.rdoc_dir = 'doc' # set the output directory
  rd.rdoc_files.add(['README', 'LICENSE', 'CHANGELOG', 'lib/**/*.rb', 'examples/**/*.rb']) # List of files to include in the rdoc generation
  rd.title = 'SWX Ruby: The Ruby Implementation of SWX RPC' # Title of the RDoc documentation
  rd.options << '--inline-source' # Show method source code inline, rather than via a popup link
  rd.options << '--line-numbers' # Include line numbers in the source code
  # rd.template = "html" # Name of the template to be used by rdoc
  # rd.options << "--accessor accessorname[,..]" # comma separated list of additional class methods that should be treated like 'attr_reader' and friends.
  # rd.options << "--all" # include all methods (not just public) in the output
  # rd.options << "--charset charset" # specifies HTML character-set
  # rd.options << "--debug" # displays lots on internal stuff
  # rd.options << "--diagram" # Generate diagrams showing modules and classes using dot.
  # rd.options << "--exclude pattern" # do not process files or directories matching pattern unless they're explicitly included
  # rd.options << "--extension new=old" #  Treat files ending with .new as if they ended with .old
  # rd.options << "--fileboxes" # classes are put in boxes which represents files, where these classes reside.
  # rd.options << "--force-update" # forces to scan all sources even if newer than the flag file.
  # rd.options << "--fmt format name" # set the output formatter (html, chm, ri, xml)
  # rd.options << "--image-format gif/png/jpg/jpeg" # Sets output image format for diagrams. Default is png.
  # rd.options << "--include dir[,dir...]" #  set (or add to) the list of directories to be searched.
  # rd.options << "--merge" # when creating ri output, merge processed classes into previously documented classes of the name name
  # rd.options << "--one-file" # put all the output into a single file
  # rd.options << "--opname name" # Set the 'name' of the output. Has no effect for HTML format.
  # rd.options << "--promiscuous" # Show module/class in the files page.
  # rd.options << "--quiet" #  don't show progress as we parse
  # rd.options << "--ri" # generate output for use by 'ri.' local
  # rd.options << "--ri-site" # generate output for use by 'ri.' sitewide
  # rd.options << "--ri-system" # generate output for use by 'ri.' system wide, for Ruby installs.
  # rd.options << "--show-hash" # A name of the form #name in a comment is a possible hyperlink to an instance method name. When displayed, the '#' is removed unless this option is specified
  # rd.options << "--style stylesheet url" # specifies the URL of a separate stylesheet.
  # rd.options << "--tab-width n" # Set the width of tab characters (default 8)
  # rd.options << "--webcvs url" # Specify a URL for linking to a web frontend to CVS.    
end

desc 'Sync docs at swxruby.org'
task :sync_docs => :rdoc do
  sh('rsync -avz ./doc/* meekish@swxruby.org:/var/www/www.swxruby.org/web/docs/')
end

# =========
# = Specs =
# =========
desc 'Run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--format', 'specdoc', '--colour']
  # t.libs = ["lib", "server/lib" ]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
end