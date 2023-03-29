# frozen_string_literal: true

require_relative "../spec_helper"

describe ImageCompare::Modes::RGB do
  let(:path_1) { image_path "a" }
  let(:path_2) { image_path "darker" }
  let(:options) { {mode: :rgb} }

  subject { ImageCompare.compare(path_1, path_2, **options) }

  context "with darker" do
    it "score around 1" do
      expect(subject.score).to be <= 1
    end
  end

  context "with different images" do
    let(:path_2) { image_path "b" }

    it "score around 0.016" do
      expect(subject.score).to be <= 0.016
    end

    it "creates correct difference image" do
      expect(subject.difference_image).to eq(ImageCompare::Image.from_file(image_path("rgb_diff")))
    end
  end

  context "exclude rect" do
    let(:options) { {mode: :rgb, exclude_rect: [156, 293, 357, 171]} }
    let(:path_2) { image_path "a1" }

    it { expect(subject.difference_image).to eq ImageCompare::Image.from_file(image_path("rgb_exclude_rect")) }
    it { expect(subject.score).to eq 0 }

    context "calculates score correctly" do
      let(:path_2) { image_path "darker" }

      it { expect(subject.score).to be <= 1 }
    end
  end

  context "include rect" do
    let(:options) { {mode: :rgb, include_rect: [0, 0, 100, 100]} }
    let(:path_2) { image_path "a1" }

    it { expect(subject.difference_image).to eq ImageCompare::Image.from_file(image_path("rgb_include_rect")) }
    it { expect(subject.score).to eq 0 }

    context "calculates score correctly" do
      let(:path_2) { image_path "darker" }

      it { expect(subject.score).to be <= 1 }
    end
  end
end
