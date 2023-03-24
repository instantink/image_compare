# frozen_string_literal: true

require 'image_matcher/version'

module ImageMatcher
  class SizesMismatchError < StandardError
  end

  require 'image_matcher/matcher'
  require 'image_matcher/color_methods'

  def self.compare(path_a, path_b, **options)
    Matcher.new(**options).compare(path_a, path_b)
  end
end
