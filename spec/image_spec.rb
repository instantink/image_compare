# frozen_string_literal: true

require 'spec_helper'

describe ImageCompare::Image do
  describe 'highlight_rectangle' do
    let(:image) { described_class.new(10, 10, described_class::BLACK) }
    let(:rect) { ImageCompare::Rectangle.new(0, 0, 1, 1) }
    subject { image.highlight_rectangle(rect, :deep_purple) }

    it { expect { subject }.to raise_error(ArgumentError) }
  end
end
