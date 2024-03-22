# frozen_string_literal: true

require "image_compare/color_methods"

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

    def find_different_pixel(image, area: nil, order: :top_to_bottom)
      area = bounding_rect if area.nil?

      rows = (area.top..area.bot).to_a
      rows.reverse! if order == :bottom_to_top

      cols = (area.left..area.right).to_a

      rows.each do |y|
        cols.each do |x|
          pixel_self = self[x, y]
          pixel_image = image[x, y]
          next if pixel_self == pixel_image
          yield(pixel_self, pixel_image, x, y)
        end
      end
    end

    def find_different_row(image, area: nil, order: :top_to_bottom)
      area = bounding_rect if area.nil?

      rows_image = (0...image.height).to_a
      rows_image.reverse! if order == :bottom_to_top

      cols = (area.left..area.right).to_a

      rows_image.each do |y_image|
        cols.each do |x|
          pixel_self = self[x, y_image]
          pixel_image = image[x, y_image]
          if pixel_self != pixel_image
            yield(y_image)
          end
          next if pixel_self == pixel_image
        end
      end
    end

    def find_equal_row(image, area: nil, order: :top_to_bottom)
      area = bounding_rect if area.nil?

      rows_self = (area.top..area.bot).to_a
      rows_self.reverse! if order == :bottom_to_top

      cols = (area.left..area.right).to_a

      rows_self.each do |y_self|
        rows_image = (0...image.height).to_a
        rows_image.each do |y_image|
          equal_row = true
          cols.each do |x|
            pixel_self = self[x, y_self]
            pixel_image = image[x, y_image]
            if pixel_self != pixel_image
              equal_row = false
              break
            end
          end
          if equal_row
            yield(y_self, y_image)
            break
          end
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
