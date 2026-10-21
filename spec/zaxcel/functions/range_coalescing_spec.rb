# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::RangeCoalescing do
  describe '.coalesce' do
    it 'leaves exactly 255 arguments enumerated' do
      args = (1..255).map { |i| "A#{i}" }
      expect(described_class.coalesce(args)).to eq(args)
    end

    it 'coalesces 256 consecutive cells without mutating the input' do
      args = (1..256).map { |i| "AA#{i}" }.freeze
      expect(described_class.coalesce(args)).to eq(['AA1:AA256'])
    end

    it 'preserves order, duplicates, gaps, and column boundaries' do
      padding = Array.new(256, '0')
      args = %w[A1 A2 A2 A3 A5 A7 A8 B9 B10 B8 B7]
      expect(described_class.coalesce(args + padding)).to eq(
        %w[A1:A2 A2:A3 A5 A7:A8 B9:B10 B8 B7] + padding,
      )
    end

    it 'preserves literals, ranges, absolute and cross-sheet references as run boundaries' do
      padding = Array.new(256, '0')
      barriers = ['42', '"A2"', '', 'A2:A3', '$A$2', 'A$2', '$A2', "'Other sheet'!A2"]
      barriers.each do |barrier|
        args = ['A1', barrier, 'A3'] + padding
        expect(described_class.coalesce(args)).to eq(args)
      end
    end

    it 'leaves oversized non-contiguous arguments unchanged' do
      args = (1..519).step(2).map { |i| "A#{i}" }
      expect(described_class.coalesce(args)).to eq(args)
    end

    it 'handles empty arguments' do
      expect(described_class.coalesce([])).to eq([])
    end
  end
end
