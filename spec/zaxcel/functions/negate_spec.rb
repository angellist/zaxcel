# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Negate do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('sheet')

    sheet.add_column!(:column)
    sheet.add_row!(:row).add!(:column, value: 1)

    sheet
  end

  before do
    sheet.position_rows!
  end

  it 'works with a numeric' do
    expect(described_class.new(1.2).format(on_sheet: 'sheet')).to eq('-1.2')
  end

  it 'works with a cell reference' do
    expect(described_class.new(sheet.cell_ref(:column, :row)).format(on_sheet: 'sheet')).to eq('-A1')
  end

  it 'works with a cell reference that does not resolve' do
    expect(described_class.new(sheet.cell_ref(:column, :not_found_row)).format(on_sheet: 'sheet')).to eq('0')
  end

  it 'wraps sums in parantheses' do
    expect(described_class.new(sheet.cell_ref(:column, :row) + 1.2).format(on_sheet: 'sheet')).to eq('-(A1+1.2)')
  end
end
