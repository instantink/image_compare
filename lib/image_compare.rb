# frozen_string_literal: true

require 'image_compare/version'

module ImageCompare
  class SizesMismatchError < StandardError
  end

  require 'image_compare/color_methods'
  require 'image_compare/matcher'

  def self.compare(path_a, path_b, **options)
    Matcher.new(**options).compare(path_a, path_b)
  end
end
