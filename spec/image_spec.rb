# frozen_string_literal: true

require "spec_helper"

describe ImageCompare::Image do
  describe "highlight_rectangle" do
    let(:image) { described_class.new(10, 10, described_class::BLACK) }
    let(:rect) { ImageCompare::Rectangle.new(0, 0, 1, 1) }
    subject { image.highlight_rectangle(rect, :deep_purple) }

    it { expect { subject }.to raise_error(ArgumentError) }
  end

  describe "compare_each_pixel" do
    let(:width) { 478 }
    let(:height) { 323 }
    let(:image) { described_class.new(width, height, ChunkyPNG::Color::WHITE) }
    let(:other_image) { described_class.new(width, height, ChunkyPNG::Color::BLACK) }
    let(:area) { ImageCompare::Rectangle.new(0, 0, width - 1, height - 1) }

    context "when order is top_to_bottom" do
      it "compares each pixel from top to bottom" do
        expect { |b| image.find_different_pixel(other_image, area: area, order: :top_to_bottom, &b) }.to yield_control.exactly(width * height).times
      end
    end

    context "when order is bottom_to_top" do
      it "compares each pixel from bottom to top" do
        expect { |b| image.find_different_pixel(other_image, area: area, order: :bottom_to_top, &b) }.to yield_control.exactly(width * height).times
      end
    end

    context "when order is invalid" do
      it "does not raise an ArgumentError" do
        expect { image.find_different_pixel(other_image, area: area, order: :invalid_order) {} }.not_to raise_error
      end
    end

    context "when no area is provided" do
      it "compares each pixel from top to bottom" do
        expect { |b| image.find_different_pixel(other_image, order: :top_to_bottom, &b) }.to yield_control.exactly(width * height).times
      end
    end

    context "when images are the same" do
      let(:same_image) { described_class.new(width, height, ChunkyPNG::Color::WHITE) }

      it "does not yield" do
        expect { |b| image.find_different_pixel(same_image, area: area, order: :top_to_bottom, &b) }.not_to yield_control
      end
    end
  end
end
