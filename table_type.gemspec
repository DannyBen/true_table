lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
require 'table_type/version'

Gem::Specification.new do |s|
  s.name        = 'table_type'
  s.version     = TableType::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Simple and intuitive tabular data type"
  s.description = "Simple and intuitive tabular data type"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  # s.executables = ["table_type"]
  s.homepage    = 'https://github.com/dannyben/table_type'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.4.0"

  # s.add_runtime_dependency 'mister_bin', '~> 0.2'
end
