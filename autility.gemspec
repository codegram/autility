# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "autility/version"

Gem::Specification.new do |s|
  s.name        = "autility"
  s.version     = Autility::VERSION
  s.authors     = ["Josep M. Bach"]
  s.email       = ["josep.m.bach@gmail.com"]
  s.homepage    = "http://github.com/codegram/autility"
  s.summary     = %q{Downloads utility invoices from common spanish firms such as Endesa or Vodafone.}
  s.description = %q{Downloads utility invoices from common spanish firms such as Endesa or Vodafone.}

  s.rubyforge_project = "utilities"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capybara"
  s.add_runtime_dependency "capybara-webkit"
  s.add_runtime_dependency "show_me_the_cookies"
  s.add_runtime_dependency "commander"
  s.add_development_dependency "mocha"
  s.add_development_dependency "minitest"
end
