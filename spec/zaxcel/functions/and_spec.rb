# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::And do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('calc')
    sheet.add_column!(:true)
    sheet.add_column!(:false)
    sheet.add_row!(:simple)
      .add!(:true, value: true)
      .add!(:false, value: false)

    sheet
  end

  before do
    sheet.position_rows!
  end

  describe 'AND' do
    it 'works on booleans' do
      formula = described_class.new(false, true)
      expect(formula.format(on_sheet: sheet.name)).to eq('AND(FALSE,TRUE)')
    end

    it 'works on cell refs' do
      formula = described_class.new(sheet.cell_ref(:true, :simple), sheet.cell_ref(:false, :simple))
      expect(formula.format(on_sheet: sheet.name)).to eq('AND(A1,B1)')
    end

    it 'works on comparison operations' do
      formula = described_class.new(
        Zaxcel::BinaryExpressions.less_than_equal(1, -10),
        sheet.cell_ref(:false, :simple),
      )
      expect(formula.format(on_sheet: sheet.name)).to eq('AND(1<=-10,B1)')
    end
  end
end
