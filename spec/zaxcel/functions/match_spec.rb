# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Match do
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
    expect(described_class.new(value: 'TEST', range: range).format(on_sheet: 'sheet')).to eq('MATCH("TEST",A1:B1)')
  end

  it 'works with a cell reference' do
    range = Zaxcel::References::Range.new(sheet.cell_ref(:column, :row), sheet.cell_ref(:column_2, :row))
    expect(described_class.new(value: sheet.cell_ref(:column_2, :row_2), range: range).format(on_sheet: 'sheet')).to eq('MATCH(B2,A1:B1)')
  end

  it 'works with a string and match_type' do
    range = Zaxcel::References::Range.new(sheet.cell_ref(:column, :row), sheet.cell_ref(:column_2, :row))
    expect(described_class.new(value: 'TEST', range: range, match_type: Zaxcel::Functions::Match::MatchType::EXACT).format(on_sheet: 'sheet')).to eq('MATCH("TEST",A1:B1,0)')
  end
end
