# frozen_string_literal: true

require_relative "../spec_helper"

describe ImageCompare::Modes::Delta do
  let(:path_1) { image_path "a" }
  let(:path_2) { image_path "darker" }
  let(:options) { {mode: :delta} }

  subject { ImageCompare.compare(path_1, path_2, **options) }

  context "with darker image" do
    it "score around 0.15" do
      expect(subject.send(:score)).to be <= 0.15
    end

    context "with custom threshold" do
      subject { ImageCompare.compare(path_1, path_2, **options).match? }

      context "below score" do
        let(:options) { {mode: :delta, threshold: 0} }

        it { expect(subject).to be_falsey }
      end

      context "above score" do
        let(:options) { {mode: :delta, threshold: 1} }

        it { expect(subject).to be_truthy }
      end

      context "with lower threshold" do
        let(:options) { {mode: :delta, threshold: 0.1, lower_threshold: 0.09} }

        it { expect(subject).to be_falsey }
      end
    end
  end

  context "with different images" do
    let(:path_2) { image_path "a1" }

    it "score around 0.0046" do
      expect(subject.send(:score)).to be <= 0.0046
    end

    it "creates correct difference image" do
      expect(subject.difference_image).to eq(ImageCompare::Image.from_file(image_path("delta_diff")))
    end

    context "with high tolerance" do
      let(:options) { {mode: :delta, tolerance: 0.1} }

      it "score around 0.0038" do
        expect(subject.send(:score)).to be <= 0.0038
      end
    end
  end
end
