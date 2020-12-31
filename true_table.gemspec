lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'true_table'
  s.version     = "0.2.1"
  s.date        = Date.today.to_s
  s.summary     = "Simple and intuitive tabular data type"
  s.description = "Simple and intuitive tabular data type"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/true_table'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.7.0"
end
