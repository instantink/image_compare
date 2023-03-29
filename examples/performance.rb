# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "benchmark/ips"
require "image_compare"

a = ImageCompare::Image.from_file(File.expand_path("../../spec/fixtures/a.png", __FILE__))
b = ImageCompare::Image.from_file(File.expand_path("../../spec/fixtures/b.png", __FILE__))

color = ImageCompare::Matcher.new
delta = ImageCompare::Matcher.new mode: :delta
grayscale = ImageCompare::Matcher.new mode: :grayscale
rgb = ImageCompare::Matcher.new mode: :delta

Benchmark.ips do |x|
  x.report "Color" do
    color.compare(a, b)
  end

  x.report "Delta E" do
    delta.compare(a, b)
  end

  x.report "Grayscale" do
    grayscale.compare(a, b)
  end

  x.report "RGB" do
    rgb.compare(a, b)
  end

  x.compare!
end

Benchmark.ips do |x|
  x.report "Color" do
    color.compare(a, b).difference_image
  end

  x.report "Delta E" do
    delta.compare(a, b).difference_image
  end

  x.report "Grayscale" do
    grayscale.compare(a, b).difference_image
  end

  x.report "RGB" do
    rgb.compare(a, b).difference_image
  end

  x.compare!
end
