# frozen_string_literal: true

require_relative "../spec_helper"

describe ImageCompare::Modes::Grayscale do
  let(:path_1) { image_path "a" }
  let(:path_2) { image_path "darker" }
  let(:options) { {mode: :grayscale} }

  subject { ImageCompare.compare(path_1, path_2, **options) }

  context "darker image" do
    it "score around 0.94" do
      expect(subject.send(:score)).to be <= 0.94
    end
  end

  context "different images" do
    let(:path_2) { image_path "a1" }

    it "score around 0.005" do
      expect(subject.score).to be <= 0.005
    end

    it "creates correct difference image" do
      expect(subject.difference_image).to eq(ImageCompare::Image.from_file(image_path("grayscale_diff")))
    end
  end

  context "with zero tolerance" do
    let(:options) { {mode: :grayscale, tolerance: 0} }

    context "darker image" do
      it "score less than 1" do
        expect(subject.score).to be <= 1
      end
    end

    context "different image" do
      let(:path_2) { image_path "b" }

      it "score around 0.016" do
        expect(subject.score).to be <= 0.016
      end
    end

    context "equal image" do
      let(:path_2) { image_path "a" }

      it "score equals to 0" do
        expect(subject.score).to eq 0
      end
    end
  end

  context "with small tolerance" do
    let(:options) { {mode: :grayscale, tolerance: 8} }

    context "darker image" do
      it "score around 0.96" do
        expect(subject.score).to be <= 0.96
      end
    end

    context "different image" do
      let(:path_2) { image_path "a1" }

      it "score around 0.006" do
        expect(subject.score).to be <= 0.006
      end
    end
  end
end
