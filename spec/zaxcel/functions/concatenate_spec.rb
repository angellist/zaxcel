# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Concatenate do
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

  it 'works with an assortment of values' do
    expect(described_class.new([1.2, sheet.cell_ref(:column, :row), 'Hello']).format(on_sheet: 'sheet')).to eq('CONCATENATE(1.2,A1,"Hello")')
  end
end
