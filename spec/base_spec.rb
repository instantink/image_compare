# frozen_string_literal: true

require "spec_helper"
require "image_compare"

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

    context "with undefined mode" do
      it "raises an ArgumentError" do
        expect { ImageCompare::Matcher.new(mode: :gamma) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "compare" do
    let(:path_1) { image_path "very_small" }
    let(:path_2) { image_path "very_small" }
    let(:path_3) { image_path "a" }
    let(:path_4) { image_path "a1" }

    it "compares two images and returns a Result object" do
      result = ImageCompare.compare(path_1, path_2)
      expect(result).to be_a ImageCompare::Result
    end

    context "when sizes mismatch" do
      let(:path_2) { image_path "small" }

      it "raises a SizesMismatchError" do
        expect { ImageCompare.compare(path_1, path_2) }.to raise_error ImageCompare::SizesMismatchError
      end
    end

    context "with negative exclude rect bounds" do
      let(:options) { {exclude_rects: [[-1, -1, -1, -1]]} }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_1, path_2, **options)
        expect(result).to be_a ImageCompare::Result
      end
    end

    context "with big exclude rect bounds" do
      let(:options) { {exclude_rects: [[100, 100, 100, 100]]} }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_1, path_2, **options)
        expect(result).to be_a ImageCompare::Result
      end
    end

    context "with negative include rect bounds" do
      let(:options) { {include_rect: [-1, -1, -1, -1]} }

      it "raises an ArgumentError" do
        expect { ImageCompare.compare(path_1, path_2, **options) }.to raise_error ArgumentError
      end
    end

    context "with big include rect bounds" do
      let(:options) { {include_rect: [100, 100, 100, 100]} }

      it "raises an ArgumentError" do
        expect { ImageCompare.compare(path_1, path_2, **options) }.to raise_error ArgumentError
      end
    end

    context "with wrong include and exclude rects combination" do
      let(:options) { {include_rect: [1, 1, 2, 2], exclude_rects: [[0, 0, 1, 1]]} }

      it "raises an ArgumentError" do
        expect { ImageCompare.compare(path_1, path_2, **options) }.to raise_error ArgumentError
      end
    end

    context "with multiple exclude rects" do
      let(:options) { {exclude_rects: [[170, 221, 188, 246], [289, 221, 307, 246]]} }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_3, path_4, **options)
        result.difference_image.save("multiple_exclude_rects.png")

        expect(result).to be_a ImageCompare::Result
        expect(result.send(:score)).to be 0.0
      end
    end

    context "with multiple exclude rects with one difference" do
      let(:options) { {exclude_rects: [[179, 221, 188, 246], [289, 221, 307, 246]]} }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_3, path_4, **options)
        result.difference_image.save("multiple_exclude_rects_with_one_difference.png")

        expect(result).to be_a ImageCompare::Result
        expect(result.send(:score)).to be > 0 and be < 1
      end
    end

    context "with multiple exclude rects with multiple differences" do
      let(:options) { {exclude_rects: [[179, 221, 188, 246], [289, 221, 298, 246]]} }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_3, path_4, **options)
        result.difference_image.save("multiple_exclude_rects_with_multiple_differences.png")

        expect(result).to be_a ImageCompare::Result
        expect(result.send(:score)).to be > 0 and be < 1
      end
    end

    context "with vertically " do
      let(:path_1) { image_path "1" }
      let(:path_2) { image_path "2" }

      it "compares two images and returns a Result object" do
        result = ImageCompare.compare(path_1, path_2)
        result.difference_image.save("abra.png")

        expect(result).to be_a ImageCompare::Result
        expect(result.send(:score)).to be > 0 and be < 1
      end
    end


  end
end
