# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::BinaryExpressions::Multiplication do
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

  describe 'distributive?' do
    it 'works for multiplication' do
      expression = described_class.new(0, 0)
      expect(expression.send(:distributive?, '-')).to be(true)
      expect(expression.send(:distributive?, '+')).to be(true)
      expect(expression.send(:distributive?, '/')).to be(false)
      expect(expression.send(:distributive?, '*')).to be(false)
      expect(expression.send(:distributive?, '<>')).to be(false)
    end
  end
end
