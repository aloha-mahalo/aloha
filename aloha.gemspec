# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aloha/version"

Gem::Specification.new do |s|
  s.name        = "aloha"
  s.version     = Aloha::VERSION
  s.authors     = ["mahalo"]
  s.email       = ["mahalo.at.github@gmail.com"]
  s.homepage    = "https://github.com/aloha-mahalo/aloha"
  s.summary     = %q{Aloha-USB ruby adapter}
  s.description = %q{helps you to capture caller information from Aloha-USB http://www.nikko-ew.co.jp/CTI/aloha_usb.html}

  s.rubyforge_project = "aloha"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rb-fsevent' if RUBY_PLATFORM =~ /darwin/i
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'guard-spork'
  s.add_development_dependency 'timecop'
  
  s.add_runtime_dependency 'serialport', '>=1.0.4'
  s.add_runtime_dependency 'activesupport'
end
