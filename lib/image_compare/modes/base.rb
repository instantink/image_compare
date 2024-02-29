# frozen_string_literal: true

module ImageCompare
  module Modes
    class Base
      require "image_compare/rectangle"
      include ColorMethods

      attr_reader :result, :threshold, :lower_threshold, :different_areas, :exclude_rects, :include_rect

      def initialize(threshold: 0.0, lower_threshold: 0.0, exclude_rects: [], include_rect: nil)
        @include_rect = Rectangle.new(*include_rect) unless include_rect.nil?
        @exclude_rects = @exclude_rects = exclude_rects.empty? ? Set.new : Set.new(exclude_rects.map { |rect| Rectangle.new(*rect) })
        @threshold = threshold
        @lower_threshold = lower_threshold
        @result = Result.new(self, threshold: threshold, lower_threshold: lower_threshold)
        @different_areas = Set.new@different_areas = Set.new
      end

      def compare(a, b)
        result.image = a
        @include_rect ||= a.bounding_rect
        b.compare_each_pixel(a, area: include_rect) do |b_pixel, a_pixel, x, y|
          next if @exclude_rects.any? { |rect| rect.contains_point?(x, y) }
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

        diff_image = create_diff_image(bg, diff_image)
        @different_areas.each do |area|
          diff_image = diff_image.highlight_rectangle(area)
        end

        diff_image.highlight_rectangle(include_rect, :green)
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
        connected_areas, disconnected_areas = @different_areas.partition { |area| origin_area.rect_close_to_the_area?(area) }
        merged_area = connected_areas.reduce(origin_area, :merge)
        @different_areas = disconnected_areas.to_set
        @different_areas.add(merged_area)
      end

      def create_area(x, y)
        @different_areas.add(Rectangle.new(x, y, x, y))
      end

      def update_bounds(x, y)
        current_area = @different_areas.find { |area| area.close_to_the_area?(x, y) }
        if current_area.nil?
          create_area(x, y)
          current_area = @different_areas.to_a.last
        else
          current_area.left = [x, current_area.left].min
          current_area.top = [y, current_area.top].min
          current_area.right = [x, current_area.right].max
          current_area.bot = [y, current_area.bot].max
        end

        areas_connected?(current_area)
        current_area
      end

      def area
        total_area = @include_rect.area
        total_exclude_area = @exclude_rects.nil? ? 0 : @exclude_rects.sum { |rect| rect.area }
        total_area - total_exclude_area
      end
    end
  end
end
