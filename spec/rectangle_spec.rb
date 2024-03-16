# frozen_string_literal: true

require "spec_helper"

describe ImageCompare::Rectangle do
  let(:rect) { described_class.new(0, 0, 9, 9) }
  let(:rect1) { described_class.new(0, 0, 2, 2) }
  let(:rect2) { described_class.new(1, 1, 3, 3) }
  let(:rect3) { described_class.new(4, 4, 6, 6) }

  describe "area" do
    subject { rect.area }

    it { expect(subject).to eq 100 }
  end

  describe "shrink_area" do
    context "normal shrink" do
      subject { rect.shrink_area(5, 5) }

      it { expect(subject.area).to eq 25 }
    end

    context "reverse shrink" do
      subject { rect.shrink_area(5, 5, :bot_to_top) }

      it { expect(subject.area).to eq 25 }
    end

    context "shrink with x zero" do
      subject { rect.shrink_area(0, 5) }

      it { expect(subject.area).to eq 50 }
    end

    context "shrink with y zero" do
      subject { rect.shrink_area(5, 0) }

      it { expect(subject.area).to eq 50 }
    end
  end

  describe "contains?" do
    let(:rect2) { described_class.new(1, 1, 8, 8) }
    subject { rect.contains?(rect2) }

    it { expect(subject).to be_truthy }

    context "when does not contain" do
      let(:rect2) { described_class.new(2, 2, 10, 10) }

      it { expect(subject).to be_falsey }
    end
  end

  describe "contains_point?" do
    let(:point) { [5, 5] }
    subject { rect.contains_point?(*point) }

    it { expect(subject).to be_truthy }

    context "when does not contain" do
      let(:point) { [10, 10] }

      it { expect(subject).to be_falsey }
    end
  end

  describe "#close_to_the_area?" do
    it "returns true if the point is close to the rectangle" do
      expect(rect1.close_to_the_area?(1, 1)).to be_truthy
    end

    it "returns false if the point is not close to the rectangle" do
      expect(rect1.close_to_the_area?(5, 5)).to be_falsey
    end
  end

  describe "#rect_close_to_the_area?" do
    it "returns true if the rectangle is close to the other rectangle" do
      expect(rect1.rect_close_to_the_area?(rect2)).to be_truthy
    end

    it "returns false if the rectangle is not close to the other rectangle" do
      expect(rect1.rect_close_to_the_area?(rect3)).to be_falsey
    end
  end

  describe "#overlaps?" do
    it "returns true if the rectangle overlaps with the other rectangle" do
      expect(rect1.overlaps?(rect2.left, rect2.top, rect2.bot, rect2.right)).to be_truthy
    end

    it "returns false if the rectangle does not overlap with the other rectangle" do
      expect(rect1.overlaps?(rect3.left, rect3.top, rect3.bot, rect3.right)).to be_falsey
    end
  end

  describe "#merge" do
    it "returns a new rectangle that covers the combined area of both rectangles" do
      merged_rect = rect1.merge(rect2)
      expect(merged_rect.left).to eq(0)
      expect(merged_rect.top).to eq(0)
      expect(merged_rect.right).to eq(3)
      expect(merged_rect.bot).to eq(3)
    end
  end
end
