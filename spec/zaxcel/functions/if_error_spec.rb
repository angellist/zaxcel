# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::IfError do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('calc')

    calc_sheet.add_column!(:function)
    calc_sheet.add_column!(:value)
    calc_sheet.add_column!(:default)

    calc_sheet.add_row!(:iferror)
      .add!(:function, value: described_class.new(calc_sheet.cell_ref(:value, :iferror), default_value: calc_sheet.cell_ref(:default, :iferror)))
      .add!(:value, value: 'ERROR_VALUE')
      .add!(:default, value: 0)

    calc_sheet
  end

  it 'formats as expected' do
    sheet.position_rows!

    expect(sheet.row(:iferror).cell(:function).value.format(on_sheet: sheet.name)).to eq('IFERROR(B1,C1)')
  end
end
