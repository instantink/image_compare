# frozen_string_literal: true

require "spec_helper"

describe ImageCompare::Matcher do
  describe "new" do
    subject { ImageCompare::Matcher.new(**options) }

    context "without options" do
      let(:options) { {} }

      it { expect(subject.mode.threshold).to eq 0 }
      it { expect(subject.mode).to be_a ImageCompare::Modes::Color }
    end

    context "with custom thresholds" do
      let(:options) { {threshold: 0.1, lower_threshold: 0.04} }

      it { expect(subject.mode.threshold).to eq 0.1 }
      it { expect(subject.mode.lower_threshold).to eq 0.04 }
    end

    context "with undefined mode" do
      let(:options) { {mode: :gamma} }

      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe "compare" do
    let(:path_1) { image_path "very_small" }
    let(:path_2) { image_path "very_small" }
    let(:options) { {} }
    subject { ImageCompare.compare(path_1, path_2, **options) }

    it { expect(subject).to be_a ImageCompare::Result }

    context "when sizes mismatch" do
      let(:path_2) { image_path "small" }
      it { expect { subject }.to raise_error ImageCompare::SizesMismatchError }
    end

    context "with negative exclude rect bounds" do
      let(:options) { {exclude_rects: [[-1, -1, -1, -1]]} }
      it { expect(subject).to be_a ImageCompare::Result }
    end

    context "with big exclude rect bounds" do
      let(:options) { {exclude_rects: [[100, 100, 100, 100]]} }
      it { expect(subject).to be_a ImageCompare::Result }
    end

    context "with negative include rect bounds" do
      let(:options) { {include_rect: [-1, -1, -1, -1]} }
      it { expect { subject }.to raise_error ArgumentError }
    end

    context "with big include rect bounds" do
      let(:options) { {include_rect: [100, 100, 100, 100]} }
      it { expect { subject }.to raise_error ArgumentError }
    end

    context "with wrong include and exclude rects combination" do
      let(:options) { {include_rect: [1, 1, 2, 2], exclude_rects: [[0, 0, 1, 1]]} }
      it { expect { subject }.to raise_error ArgumentError }
    end
  end
end
