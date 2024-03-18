# frozen_string_literal: true

module ImageCompare
  class Matcher
    require "image_compare/image"
    require "image_compare/result"
    require "image_compare/modes"

    MODES = {
      rgb: "RGB",
      delta: "Delta",
      grayscale: "Grayscale",
      color: "Color"
    }.freeze

    attr_reader :mode

    def initialize(**options)
      mode_type = options.delete(:mode) || :color
      raise ArgumentError, "Undefined mode: #{mode_type}" unless MODES.key?(mode_type)
      @mode = Modes.const_get(MODES[mode_type]).new(**options)
    end

    def compare(a, b)
      a = Image.from_file(a) unless a.is_a?(Image)
      b = Image.from_file(b) unless b.is_a?(Image)

      unless a.sizes_match?(b)
        raise(
          SizesMismatchError,
          "Size mismatch: first image size: #{a.width}x#{a.height}, second image size: #{b.width}x#{b.height}"
        )
      end

      image_area = Rectangle.new(0, 0, a.width - 1, a.height - 1)

      unless mode.include_rect.nil?
        unless image_area.contains?(mode.include_rect)
          raise ArgumentError, "Bounds must be in image"
        end

        mode.exclude_rects&.each do |exclude_rect|
          unless mode.include_rect.contains?(exclude_rect)
            raise ArgumentError, "Included area must contain excluded"
          end
        end
      end

      mode.compare(a, b)
    end
  end
end
