# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::Or do
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

  describe 'OR' do
    it 'works on booleans' do
      formula = described_class.new(false, true)
      expect(formula.format(on_sheet: sheet.name)).to eq('OR(FALSE,TRUE)')
    end

    it 'works on strings' do
      formula = described_class.new('hello, world', true)
      expect(formula.format(on_sheet: sheet.name)).to eq('OR("hello, world",TRUE)')
    end

    it 'works on cell refs' do
      formula = described_class.new(
        sheet.cell_ref(:true, :simple),
        sheet.cell_ref(:false, :simple),
      )

      sheet.position_rows!

      expect(formula.format(on_sheet: sheet.name)).to eq('OR(A1,B1)')
    end
  end
end
