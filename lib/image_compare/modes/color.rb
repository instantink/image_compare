# frozen_string_literal: true

module ImageCompare
  module Modes
    require "image_compare/modes/base"

    class Color < Base
      include ColorMethods

      DEFAULT_TOLERANCE = 16

      attr_reader :tolerance

      def initialize(**options)
        @tolerance = options.delete(:tolerance) || DEFAULT_TOLERANCE
        super(**options)
      end

      def diff(bg, _diff)
        diff_image = bg.highlight_rectangle(exclude_rect, :blue)

        unless result.match? || area_in_exclude_rect?
          return diff_image.highlight_rectangle(bounds, :red)
        end

        diff_image
      end

      def area_in_exclude_rect?
        return false if exclude_rect.nil?

        diff_area = {
          left: bounds.bounds[0],
          top: bounds.bounds[1],
          right: bounds.bounds[2],
          bot: bounds.bounds[3]
        }

        exclude_area = {
          left: exclude_rect.bounds[0],
          top: exclude_rect.bounds[1],
          right: exclude_rect.bounds[2],
          bot: exclude_rect.bounds[3]
        }

        diff_area[:left] <= exclude_area[:left] &&
          diff_area[:top] <= exclude_area[:top] &&
          diff_area[:right] >= exclude_area[:right] &&
          diff_area[:bot] >= exclude_area[:bot]
      end

      def pixels_equal?(a, b)
        alpha = color_similar?(a(a), a(b))
        brightness = color_similar?(brightness(a), brightness(b))
        brightness && alpha
      end

      def update_result(a, b, x, y)
        super
        @result.diff << [a, b, x, y]
      end

      def color_similar?(a, b)
        d = (a - b).abs
        d <= tolerance
      end
    end
  end
end
