# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flowdock-api/version"

Gem::Specification.new do |s|
  s.name        = "flowdock-api"
  s.version     = FlowdockApi::VERSION
  s.email       = ["team@flowdock.com"]
  s.homepage    = "https://www.flowdock.com/api"
  s.summary     = %q{Ruby Gem for using Flowdock's public API.}
  s.description = %q{Ruby Gem for using Flowdock's public API.}

  s.rubyforge_project = "flowdock-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("httparty", "~>0.7.8")
  s.add_development_dependency("rspec")
  s.add_development_dependency("fakeweb", "~>1.3.0")
end
