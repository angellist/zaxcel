# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Unique do
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

  it 'works with a range' do
    range = Zaxcel::References::Range.new(sheet.cell_ref(:column, :row), sheet.cell_ref(:column_2, :row))
    expect(described_class.new(range).format(on_sheet: 'sheet')).to eq('UNIQUE(A1:B1)')
  end
end
