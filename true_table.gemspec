lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
require 'true_table/version'

Gem::Specification.new do |s|
  s.name        = 'true_table'
  s.version     = TrueTable::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Simple and intuitive tabular data type"
  s.description = "Simple and intuitive tabular data type"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  # s.executables = ["true_table"]
  s.homepage    = 'https://github.com/dannyben/true_table'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.4.0"

  # s.add_runtime_dependency 'mister_bin', '~> 0.2'
end
