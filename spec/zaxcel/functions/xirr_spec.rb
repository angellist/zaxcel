# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Xirr do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('sheet')

    sheet.add_column!(:column_1)
    sheet.add_column!(:column_2)
    sheet.add_row!(:row_1)
      .add!(:column_1, value: 0)
      .add!(:column_2, value: 1)
    sheet.add_row!(:row_2)
      .add!(:column_1, value: 2)
      .add!(:column_2, value: 3)

    sheet
  end

  before do
    sheet.position_rows!
  end

  it 'formats as expected' do
    values = Zaxcel::References::Range.new(
      sheet.cell_ref(:column_1, :row_1),
      sheet.cell_ref(:column_1, :row_2),
    )
    dates = Zaxcel::References::Range.new(
      sheet.cell_ref(:column_2, :row_1),
      sheet.cell_ref(:column_2, :row_2),
    )
    expect(described_class.new(values, dates).format(on_sheet: 'sheet')).to eq('XIRR(A1:A2,B1:B2)')
  end
end
