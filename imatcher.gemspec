# frozen_string_literal: true

require_relative 'lib/image_matcher/version'

Gem::Specification.new do |spec|
  spec.name = 'image_matcher'
  spec.version = ImageMatcher::VERSION
  spec.authors = %w[cristianofmc gsguma]
  spec.email = %w[cristianofmc@gmail.com giltonguma@gmail.com]
  spec.summary = 'Image comparison lib'
  spec.description = 'Image comparison lib built on top of ChunkyPNG'
  spec.homepage = 'https://github.com/instantink/image_matcher'
  spec.license = 'MIT'
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/instantink/image_matcher/issues',
    'changelog_uri' => 'https://github.com/instantink/image_matcher/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/instantink/image_matcher',
    'homepage_uri' => 'https://github.com/instantink/image_matcher',
    'source_code_uri' => 'https://github.com/instantink/image_matcher'
  }

  spec.files = Dir.glob('lib/**/*') + Dir.glob('bin/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.2.0'
  spec.add_dependency 'chunky_png'
  spec.add_development_dependency 'rake', '>= 13.0'
  spec.add_development_dependency 'rspec', '>= 3.9'
end
