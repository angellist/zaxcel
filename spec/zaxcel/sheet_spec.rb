# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::BinaryExpression do
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

  let(:a1_reference) { sheet.cell_ref(:first, :simple) }
  let(:b1_reference) { sheet.cell_ref(:last, :simple) }

  before do
    sheet.position_rows!
  end

  describe 'format_cell_contents' do
    it 'works with a cell formula' do
      cell = Zaxcel::Cell.new(
        column: sheet.columns.first!,
        row: sheet.rows.first!,
        style: :default_cell,
        value: 1.234 + a1_reference,
      )
      expect(sheet.send(:format_cell_contents, cell)).to eq('=1.234+A1')
    end

    it 'works with a numeric' do
      cell = Zaxcel::Cell.new(
        column: sheet.columns.first!,
        row: sheet.rows.first!,
        value: 1.234,
        style: :default_cell,
      )
      expect(sheet.send(:format_cell_contents, cell)).to eq(1.234)
    end

    it 'works with an array cell formula' do
      range = Zaxcel::References::Range.new(a1_reference, b1_reference)
      unique_formula = Zaxcel::Functions::Unique.new(range, array_formula: true)

      cell = Zaxcel::Cell.new(
        column: sheet.columns.first!,
        row: sheet.rows.first!,
        style: :default_cell,
        value: unique_formula,
      )
      expect(sheet.send(:format_cell_contents, cell)).to eq('{=UNIQUE(A1:B1)}')
    end
  end
end
