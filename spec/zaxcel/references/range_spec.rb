# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::References::Range do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('binary_expressions')

    calc_sheet.add_column!(:first)
    calc_sheet.add_column!(:last)

    calc_sheet.add_row!(:simple)
      .add!(:first, value: 0)
      .add!(:last, value: 1)

    calc_sheet
  end

  it 'row range works intra-sheet' do
    range = Zaxcel::Lang.range(sheet.cell_ref(:first, :simple), sheet.cell_ref(:last, :simple))
    sheet.position_rows!
    expect(range.format(on_sheet: sheet.name)).to eq('A1:B1')
  end

  it 'row range works inter-sheet' do
    range = Zaxcel::Lang.range(sheet.cell_ref(:first, :simple), sheet.cell_ref(:last, :simple))
    sheet.position_rows!
    expect(range.format(on_sheet: 'other')).to eq("'binary_expressions'!A1:B1")
  end

  it 'column range works intra-sheet' do
    range = Zaxcel::Lang.range(sheet.column_ref(:first))
    sheet.position_rows!
    expect(range.format(on_sheet: sheet.name)).to eq('A:A')
  end

  it 'column range works inter-sheet' do
    range = Zaxcel::Lang.range(sheet.column_ref(:first))
    sheet.position_rows!
    expect(range.format(on_sheet: 'other')).to eq("'binary_expressions'!A:A")
  end
end
