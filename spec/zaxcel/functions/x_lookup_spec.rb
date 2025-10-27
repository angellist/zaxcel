# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::XLookup do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('calc')

    calc_sheet.add_column!(:function)
    calc_sheet.add_column!(:index)
    calc_sheet.add_column!(:value)

    index_range = Zaxcel::Lang.range(calc_sheet.cell_ref(:index, :lookup_row_0), calc_sheet.cell_ref(:index, :lookup_row_3))
    value_range = Zaxcel::Lang.range(calc_sheet.cell_ref(:value, :lookup_row_0), calc_sheet.cell_ref(:value, :lookup_row_3))

    calc_sheet.add_row!(:xlookup).add!(:function, value: described_class.new(0, idx_range: index_range, value_range: value_range))

    ['Zero', 'One', 'Two', 'Three'].each_with_index do |name, index|
      calc_sheet.add_row!("lookup_row_#{index}")
        .add!(:index, value: index)
        .add!(:value, value: name)
    end

    calc_sheet
  end

  it 'formats as expected' do
    sheet.position_rows!

    expect(sheet.row(:xlookup).cell(:function).value.format(on_sheet: sheet.name)).to eq('XLOOKUP(0,B2:B5,C2:C5)')
  end
end
