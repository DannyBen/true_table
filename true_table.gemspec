lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'true_table/version'

Gem::Specification.new do |s|
  s.name        = 'true_table'
  s.version     = TrueTable::VERSION
  s.summary     = 'Simple and intuitive tabular data type'
  s.description = 'Simple and intuitive tabular data type'
  s.authors     = ['Danny Ben Shitrit']
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/true_table'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 3.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
