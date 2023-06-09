# frozen_string_literal: true

module ImageCompare
  module Modes
    require "image_compare/modes/base"

    class RGB < Base
      def pixels_equal?(a, b)
        a == b
      end

      def update_result(a, b, x, y)
        super
        @result.diff << [a, b, x, y]
      end

      def background(bg)
        Image.new(bg.width, bg.height, BLACK)
      end

      def create_diff_image(_bg, diff_image)
        diff_image
      end

      def pixels_diff(d, a, b, x, y)
        d[x, y] = rgb(
          (r(a) - r(b)).abs,
          (g(a) - g(b)).abs,
          (b(a) - b(b)).abs
        )
      end
    end
  end
end
