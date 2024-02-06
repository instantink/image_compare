# frozen_string_literal: true

module ImageCompare
  module Modes
    class Base
      require "image_compare/rectangle"
      include ColorMethods

      attr_reader :result, :threshold, :lower_threshold, :bounds, :exclude_rect, :include_rect

      def initialize(threshold: 0.0, lower_threshold: 0.0, exclude_rect: nil, include_rect: nil)
        @include_rect = Rectangle.new(*include_rect) unless include_rect.nil?
        @exclude_rect = Rectangle.new(*exclude_rect) unless exclude_rect.nil?
        @threshold = threshold
        @lower_threshold = lower_threshold
        @result = Result.new(self, threshold: threshold, lower_threshold: lower_threshold)
        @different_areas = []
      end

      def compare(a, b)
        result.image = a
        @include_rect ||= a.bounding_rect
        b.compare_each_pixel(a, area: include_rect) do |b_pixel, a_pixel, x, y|

          next if !exclude_rect.nil? && exclude_rect.contains_point?(x, y)
          next if pixels_equal?(b_pixel, a_pixel)
          update_result(b_pixel, a_pixel, x, y)
        end

        result.score = score
        result
      end

      def diff(bg, diff)
        diff_image = background(bg).highlight_rectangle(exclude_rect, :blue)
        diff.each do |pixels_pair|
          pixels_diff(diff_image, *pixels_pair)
        end

        create_diff_image(bg, diff_image)
          .highlight_rectangle(bounds)
          .highlight_rectangle(include_rect, :green)
      end

      def score
        result.diff.length.to_f / area
      end

      def update_result(*_args, x, y)
        update_bounds(x, y)
      end

      def connected_area_index(x, y)
        @different_areas.each_with_index do |area, index|
          if area.close_to_the_area?(x, y)
            return index
          end
        end
        nil
      end

      def areas_connected?(origin_area)
        @different_areas = @different_areas.reject do |area|
          if origin_area.rect_close_to_the_area?(area)
            origin_area.merge(area)
            true
          else
            false
          end
        end
      end

      def create_area(x, y)
        @different_areas << Rectangle.new(x, y, x, y)
      end

      def update_bounds(x, y)
        current_area_index = connected_area_index(x, y)
        if @different_areas.empty? || current_area_index.nil?
          create_area(x,y)
          current_area_index = @different_areas.size - 1
        end

        area = @different_areas[current_area_index]
        area.left = [x, area.left].max
        area.top = [y, area.top].max
        area.right = [x, area.right].min
        area.bot = [y, area.bot].min

        areas_connected?(area)
        area
      end

      # def update_bounds(x, y)
      #   bounds.each do |bound|
      #     bound.left = [x, bound.left].max
      #     bound.top = [y, bound.top].max
      #     bound.right = [x, bound.right].min
      #     bound.bot = [y, bound.bot].min
      #   end
      # end
      #
      # def update_bounds(x, y)
      #   bounds.each do |bound|
      #     if x >= bound.left && x <= bound.right && y >= bound.top && y <= bound.bot
      #       bound.left = x
      #       bound.top = y
      #       bound.right = x
      #       bound.bot = y
      #     end
      #   end
      #end


      def area
        area = include_rect.area
        return area if exclude_rect.nil?
        area - exclude_rect.area
      end
    end
  end
end
