# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vitalsio"
  s.version     = `cat VERSION`.strip
  s.authors     = ["Jonathan Johnson"]
  s.email       = ["jon@vitals.io"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "vitalsio"

  s.files = [
      'VERSION',
      'lib/vitalsio.rb',
      'ca.crt'
  ]
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
