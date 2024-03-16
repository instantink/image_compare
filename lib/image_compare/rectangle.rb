# frozen_string_literal: true

module ImageCompare
  class Rectangle
    attr_accessor :left, :top, :right, :bot

    OFFSETS = [-1, 0, 1].product([-1, 0, 1]).reject { |dx, dy| dx.zero? && dy.zero? }.freeze

    def initialize(l, t, r, b)
      @left = l
      @top = t
      @right = r
      @bot = b
    end

    def area
      (right - left + 1) * (bot - top + 1)
    end

    def contains?(rect)
      (left <= rect.left) &&
        (right >= rect.right) &&
        (top <= rect.top) &&
        (bot >= rect.bot)
    end

    def bounds
      [left, top, right, bot]
    end

    def contains_point?(x, y)
      x.between?(left, right) && y.between?(top, bot)
    end

    def close_to_the_area?(x, y)
      OFFSETS.any? { |dx, dy| contains_point?(x + dx, y + dy) }
    end

    def rect_close_to_the_area?(rect)
      OFFSETS.any? do |dx, dy|
        overlaps?(rect.left + dx, rect.top + dy, rect.right + dx, rect.bot + dy)
      end
    end

    def overlaps?(other_left, other_top, other_right, other_bot)
      (left <= other_right) &&
        (right >= other_left) &&
        (top <= other_bot) &&
        (bot >= other_top)
    end

    def merge(rect)
      new_left = [left, rect.left].min
      new_top = [top, rect.top].min
      new_right = [right, rect.right].max
      new_bot = [bot, rect.bot].max

      Rectangle.new(new_left, new_top, new_right, new_bot)
    end

    def shrink_area(x, y, order = :top_to_bottom)
      @left += x
      if order == :bottom_to_top
        @bot -= y
      elsif order == :top_to_bottom
        @top += y
      else
        raise ArgumentError, "Invalid order: #{order}"
      end

      if @left > right || @top > bot || @bot < top
        raise ArgumentError, "The shrink values are too large"
      end

      self
    end
  end
end
