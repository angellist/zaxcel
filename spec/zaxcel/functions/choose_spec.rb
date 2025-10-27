# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Choose do
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
    expect(described_class.new(sheet.cell_ref(:column, :row) + 1, choices: [1, '2', '3']).format(on_sheet: 'sheet')).to eq('CHOOSE(A1+1,1,"2","3")')
  end
end
