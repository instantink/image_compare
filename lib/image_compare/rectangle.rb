# frozen_string_literal: true

module ImageCompare
  class Rectangle
    attr_accessor :left, :top, :right, :bot

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
      (x >= left && y >= top && x <= right && y <= bot) ||
        (x <= right && y <= top && x >= left && y >= bot) ||
        (x.between?(right, left) && y.between?(bot, top))
    end

    def close_to_the_area?(x, y)
      offsets = [-1, 0, 1]
      offsets.product(offsets).any? do |dx, dy|
        next if dx.zero? && dy.zero?
        contains_point?(x + dx, y + dy)
      end
    end

    def rect_close_to_the_area?(rect)
      offsets = [-1, 0, 1]
      offsets.product(offsets).any? do |dx, dy|
        next if dx.zero? && dy.zero?
        new_rect = Rectangle.new(rect.left + dx, rect.top + dy, rect.right + dx, rect.bot + dy)
        overlaps?(new_rect)
      end
    end

    def overlaps?(rect)
      (left <= rect.right) &&
        (right >= rect.left) &&
        (top <= rect.bot) &&
        (bot >= rect.top)
    end

    def merge(rect)
      new_left = [left, rect.left].min
      new_top = [top, rect.top].min
      new_right = [right, rect.right].max
      new_bot = [bot, rect.bot].max

      Rectangle.new(new_left, new_top, new_right, new_bot)
    end
  end
end
