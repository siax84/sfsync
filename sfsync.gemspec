$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sfsync/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sfsync"
  s.version     = Sfsync::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "http://www.ifoam.bio"
  s.summary     = "Sync your ActiveRecord Models with Salesforce Models"
  s.description = "Description of Sfsync."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"
  s.add_dependency "restforce"  

end
