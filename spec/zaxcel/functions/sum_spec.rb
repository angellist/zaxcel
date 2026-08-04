# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Sum do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('realizations')
    amount = sheet.add_column!(:amount)
    other = sheet.add_column!(:other)
    (1..260).each do |i|
      row = sheet.add_row!(:"r#{i}")
      amount.add_cell!(row: row, value: i)
      other.add_cell!(row: row, value: i)
    end
    sheet
  end

  before { sheet.position_rows! }

  def amount_refs(rows)
    rows.map { |i| sheet.cell_ref(:amount, :"r#{i}") }
  end

  it 'renders an enumerated SUM at or below Excel argument limit' do
    refs = amount_refs(1..3)
    expected = "SUM(#{refs.map { |r| r.format(on_sheet: sheet.name) }.join(',')})"
    expect(described_class.new(refs).format(on_sheet: sheet.name)).to eq(expected)
  end

  it 'collapses a contiguous column of more than 255 cells into a single range' do
    refs = amount_refs(1..260)
    first = sheet.cell_ref(:amount, :r1).format(on_sheet: sheet.name)
    last = sheet.cell_ref(:amount, :r260).format(on_sheet: sheet.name)
    expect(described_class.new(refs).format(on_sheet: sheet.name)).to eq("SUM(#{first}:#{last})")
  end

  it 'keeps every nested SUM within the 255-argument limit for non-contiguous cells' do
    refs = (1..260).flat_map { |i| [sheet.cell_ref(:amount, :"r#{i}"), sheet.cell_ref(:other, :"r#{i}")] }
    result = described_class.new(refs).format(on_sheet: sheet.name)
    inner_arg_counts = result.scan(/SUM\(([^()]*)\)/).map { |inner| inner[0].split(',').size }
    expect(result).to start_with('SUM(SUM(')
    expect(inner_arg_counts).to all(be <= described_class::MAX_FUNCTION_ARGS)
  end

  it 'renders 0 when empty' do
    expect(described_class.new([]).format(on_sheet: sheet.name)).to eq('0')
  end
end
