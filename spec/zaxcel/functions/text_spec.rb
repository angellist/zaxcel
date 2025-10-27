# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Text do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('sheet')

    sheet.add_column!(:column)
    sheet.add_row!(:row).add!(:column, value: 0)

    sheet
  end

  before do
    sheet.position_rows!
  end

  it 'works with a cell formula' do
    expect(described_class.new(1 + sheet.cell_ref(:column, :row), format_string: 'FORMAT_STRING').format(on_sheet: 'sheet')).to eq('TEXT(1+A1,"FORMAT_STRING")')
  end
end
