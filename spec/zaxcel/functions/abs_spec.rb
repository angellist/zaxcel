# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Abs do
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
    expect(described_class.new(1.2).format(on_sheet: 'sheet')).to eq('ABS(1.2)')
  end

  it 'works with a cell reference' do
    expect(described_class.new(sheet.cell_ref(:column, :row)).format(on_sheet: 'sheet')).to eq('ABS(A1)')
  end

  it 'works with a cell reference that does not resolve' do
    expect(described_class.new(sheet.cell_ref(:column, :not_found_row)).format(on_sheet: 'sheet')).to eq('ABS(0)')
  end

  it 'works with a cell formula' do
    expect(described_class.new(sheet.cell_ref(:column, :row) + 1.2).format(on_sheet: 'sheet')).to eq('ABS(A1+1.2)')
  end
end
