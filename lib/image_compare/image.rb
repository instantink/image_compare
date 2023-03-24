# frozen_string_literal: true

require 'image_compare/color_methods'

module ImageCompare
  class Image < ChunkyPNG::Image
    include ColorMethods

    def each_pixel
      height.times do |y|
        current_row = row(y) || []
        current_row.each_with_index do |pixel, x|
          yield(pixel, x, y)
        end
      end
    end

    def compare_each_pixel(image, area: nil)
      area = bounding_rect if area.nil?
      (area.top..area.bot).each do |y|
        current_row = row(y) || []
        range = (area.left..area.right)
        next if image.row(y).slice(range) == current_row.slice(range)
        (area.left..area.right).each do |x|
          yield(self[x, y], image[x, y], x, y)
        end
      end
    end

    def to_grayscale
      each_pixel do |pixel, x, y|
        self[x, y] = grayscale(brightness(pixel).round)
      end
      self
    end

    def with_alpha(value)
      each_pixel do |pixel, x, y|
        self[x, y] = rgba(r(pixel), g(pixel), b(pixel), value)
      end
      self
    end

    def sizes_match?(image)
      [width, height] == [image.width, image.height]
    end

    def inspect
      "Image:#{object_id}<#{width}x#{height}>"
    end

    def highlight_rectangle(rect, color = :red)
      raise ArgumentError, "Undefined color: #{color}" unless respond_to?(color)
      return self if rect.nil?
      rect(*rect.bounds, send(color))
      self
    end

    def bounding_rect
      Rectangle.new(0, 0, width - 1, height - 1)
    end
  end
end
