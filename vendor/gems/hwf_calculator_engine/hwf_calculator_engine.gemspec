$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hwf_calculator_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hwf_calculator_engine"
  s.version     = HwfCalculatorEngine::VERSION
  s.authors     = ["Gary Taylor"]
  s.email       = ["gary.taylor@hismessages.com"]
  s.homepage    = "http://www.homepage.com"
  s.summary     = "Help With Fees Calculator Engine"
  s.description = "Help with fees calculator engine"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.9"
  s.add_dependency 'virtus', '~> 1.0'
  s.add_dependency 'jbuilder', '~> 2.7'
  s.add_dependency 'activerecord', '~> 4.2.9'
end
