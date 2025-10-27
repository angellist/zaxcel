# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Index do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('sheet')

    sheet.add_column!(:column)
    sheet.add_column!(:column_2)
    sheet.add_row!(:row).add!(:column, value: 1)
    sheet.add_row!(:row_2).add!(:column, value: 2)

    sheet
  end

  before do
    sheet.position_rows!
  end

  it 'works with a string' do
    range = Zaxcel::References::Range.new(sheet.cell_ref(:column, :row), sheet.cell_ref(:column_2, :row))
    expect(described_class.new(index_value: 'TEST', range: range).format(on_sheet: 'sheet')).to eq('INDEX(A1:B1,"TEST")')
  end

  it 'works with a cell reference' do
    range = Zaxcel::References::Range.new(sheet.cell_ref(:column, :row), sheet.cell_ref(:column_2, :row))
    expect(described_class.new(index_value: sheet.cell_ref(:column_2, :row_2), range: range).format(on_sheet: 'sheet')).to eq('INDEX(A1:B1,B2)')
  end
end
