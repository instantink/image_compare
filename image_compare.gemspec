# frozen_string_literal: true

require_relative 'lib/image_compare/version'

Gem::Specification.new do |spec|
  spec.name = 'image_compare'
  spec.version = ImageCompare::VERSION
  spec.authors = %w[cristianofmc gsguma]
  spec.email = %w[cristiano.fmc@hotmail.com giltonguma@gmail.com]
  spec.summary = 'Image comparison lib'
  spec.description = 'Image comparison lib built on top of ChunkyPNG'
  spec.homepage = 'https://github.com/instantink/image_compare'
  spec.license = 'MIT'
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/instantink/image_compare/issues',
    'changelog_uri' => 'https://github.com/instantink/image_compare/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/instantink/image_compare',
    'homepage_uri' => 'https://github.com/instantink/image_compare',
    'source_code_uri' => 'https://github.com/instantink/image_compare'
  }

  spec.files = Dir.glob('lib/**/*') + Dir.glob('bin/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'
  spec.add_dependency 'chunky_png'
  spec.add_development_dependency 'rake', '>= 13.0'
  spec.add_development_dependency 'rspec', '>= 3.9'
end
