require "spec_helper"
require "image_compare/modes/base"

describe ImageCompare::Modes::Base do
  let(:base) { described_class.new(threshold: 0.5, lower_threshold: 0.2) }
  let(:image_a) { double("Image") }
  let(:image_b) { double("Image") }

  before do
    allow(base).to receive(:update_result)
    allow(base).to receive(:pixels_equal?).and_return(false)
    allow(base).to receive(:score).and_return(1.0)
    allow(image_b).to receive(:compare_each_pixel)
  end

  describe '#compare' do
    it 'calls update_result when pixels are not equal' do
      base.compare(image_a, image_b)
      expect(base).to have_received(:update_result)
    end

    it 'sets the result score' do
      base.compare(image_a, image_b)
      expect(base.result.score).to eq(1.0)
    end
  end

  describe '#initialize' do
    it 'initializes with correct threshold' do
      expect(base.threshold).to eq(0.5)
    end

    it 'initializes with correct lower_threshold' do
      expect(base.lower_threshold).to eq(0.2)
    end

    it 'initializes bounds as an empty array' do
      expect(base.bounds).to eq([])
    end
  end

  describe '#not_connected' do
    it 'returns true when bounds are empty' do
      expect(base.not_connected(1, 1)).to be true
    end
  end

  describe '#update_bounds' do
    context 'when bounds are empty' do
      it 'adds a new rectangle to bounds' do
        base.update_bounds(1, 1)
        expect(base.bounds.size).to eq(1)
      end
    end

    context 'when bounds are not empty' do
      it 'updates the existing rectangle in bounds' do
        base.bounds << ImageCompare::Rectangle.new(0, 0, 2, 2)
        base.update_bounds(1, 1)
        expect(base.bounds[0].left).to eq(1)
        expect(base.bounds[0].top).to eq(1)
        expect(base.bounds[0].right).to eq(1)
        expect(base.bounds[0].bot).to eq(1)
      end
    end
  end

  describe '#score' do
    it 'returns the correct score' do
      allow(base.result).to receive(:diff).and_return([1, 2, 3])
      allow(base).to receive(:area).and_return(10)
      expect(base.score).to eq(0.3)
    end
  end

  describe '#update_result' do
    it 'calls update_bounds' do
      allow(base).to receive(:update_bounds)
      base.update_result(1, 1)
      expect(base).to have_received(:update_bounds).with(1, 1)
    end
  end

  describe '#connected_area_index' do
    context 'when there is a connected area' do
      it 'returns the index of the connected area' do
        base.instance_variable_set(:@different_areas, [ImageCompare::Rectangle.new(0, 0, 2, 2)])
        expect(base.connected_area_index(1, 1)).to eq(0)
      end
    end

    context 'when there is no connected area' do
      it 'returns nil' do
        base.instance_variable_set(:@different_areas, [])
        expect(base.connected_area_index(1, 1)).to be_nil
      end
    end
  end

  describe '#areas_connected?' do
    context 'when areas are connected' do
      it 'merges the origin area with the connected area' do
        origin_area = ImageCompare::Rectangle.new(0, 0, 2, 2)
        connected_area = ImageCompare::Rectangle.new(1, 1, 3, 3)
        base.instance_variable_set(:@different_areas, [origin_area, connected_area])
        base.areas_connected?(origin_area)
        expect(origin_area.bounds).to eq([0, 0, 3, 3])
        expect(base.instance_variable_get(:@different_areas)).to eq([])
      end
    end

    context 'when areas are not connected' do
      it 'does not merge the areas' do
        origin_area = ImageCompare::Rectangle.new(0, 0, 2, 2)
        connected_area = ImageCompare::Rectangle.new(3, 3, 4, 4)
        base.instance_variable_set(:@different_areas, [origin_area, connected_area])
        base.areas_connected?(origin_area)
        expect(origin_area.bounds).to eq([0, 0, 2, 2])
        expect(base.instance_variable_get(:@different_areas)).to eq([connected_area])
      end
    end
  end

  describe '#create_area' do
    it 'creates a new area' do
      base.create_area(1, 1)
      expect(base.instance_variable_get(:@different_areas).size).to eq(1)
      expect(base.instance_variable_get(:@different_areas)[0].bounds).to eq([1, 1, 1, 1])
    end
  end

  describe '#area' do
    context 'when exclude_rect is nil' do
      it 'returns the area of include_rect' do
        base.instance_variable_set(:@include_rect, ImageCompare::Rectangle.new(0, 0, 2, 2))
        expect(base.area).to eq(4)
      end
    end

    context 'when exclude_rect is not nil' do
      it 'returns the area of include_rect minus the area of exclude_rect' do
        base.instance_variable_set(:@include_rect, ImageCompare::Rectangle.new(0, 0, 2, 2))
        base.instance_variable_set(:@exclude_rect, ImageCompare::Rectangle.new(1, 1, 2, 2))
        expect(base.area).to eq(3)
      end
    end
  end
end