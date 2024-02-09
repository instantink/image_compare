require "spec_helper"
require "image_compare/modes/color"
require "image_compare/modes/delta"
require "image_compare/result"
require "image_compare/rectangle"

describe ImageCompare::Matcher do
  describe "new" do
    context "without options" do
      it "creates a new Matcher instance with default options" do
        matcher = ImageCompare::Matcher.new
        expect(matcher.mode.threshold).to eq 0
        expect(matcher.mode).to be_a ImageCompare::Modes::Color
      end
    end

    context "with custom thresholds" do
      it "creates a new Matcher instance with custom thresholds" do
        matcher = ImageCompare::Matcher.new(threshold: 0.1, lower_threshold: 0.04)
        expect(matcher.mode.threshold).to eq 0.1
        expect(matcher.mode.lower_threshold).to eq 0.04
      end
    end

    context "with custom options" do
      it "creates a new Matcher instance with custom options" do
        matcher = ImageCompare::Matcher.new(mode: :grayscale, tolerance: 0)
        expect(matcher.mode.tolerance).to eq 0
      end
    end

    context "with custom mode" do
      it "creates a new Matcher instance with custom mode" do
        matcher = ImageCompare::Matcher.new(mode: :delta)
        expect(matcher.mode).to be_a ImageCompare::Modes::Delta
      end
    end

    context "with undefined mode" do
      it "raises an ArgumentError" do
        expect { ImageCompare::Matcher.new(mode: :gamma) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "compare" do
    let(:path_1) { image_path "very_small" }
    let(:path_2) { image_path "very_small" }

    it "compares two images and returns a Result object" do
      result = ImageCompare.compare(path_1, path_2)
      expect(result).to be_a ImageCompare::Result
    end

    context "when sizes mismatch" do
      let(:path_2) { image_path "small" }

      it "raises a SizesMismatchError" do
        expect { ImageCompare.compare(path_1, path_2) }.to raise_error(ImageCompare::SizesMismatchError)
      end
    end

    context "with negative exclude rect bounds" do
      let(:options) { { exclude_rect: [-1, -1, -1, -1] } }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_1, path_2, **options)
        expect(result).to be_a ImageCompare::Result
      end
    end
  end
end