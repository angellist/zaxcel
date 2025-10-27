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

  describe 'distributive?' do
    it 'works for non-arithmetic operators' do
      expression = described_class.new('<=', 0, 0)
      expect(expression.send(:distributive?, '-')).to be(false)
      expect(expression.send(:distributive?, '+')).to be(false)
      expect(expression.send(:distributive?, '/')).to be(false)
      expect(expression.send(:distributive?, '*')).to be(false)
      expect(expression.send(:distributive?, '<>')).to be(false)
    end
  end

  describe 'wrap_value?' do
    it 'returns false for simple values' do
      expression = described_class.new('+', 0, 0)
      expect(expression.send(:wrap_value?, 1)).to be(false)
      expect(expression.send(:wrap_value?, '3')).to be(false)
    end

    it 'returns true for negate' do
      expression = described_class.new('+', 0, 0)
      expect(expression.send(:wrap_value?, Zaxcel::Functions::Negate.new(5))).to be(true)
    end

    it 'returns false for functions' do
      expression = described_class.new('+', 0, 0)
      expect(expression.send(:wrap_value?, Zaxcel::Functions::And.new(true, false))).to be(false)
      expect(expression.send(:wrap_value?, Zaxcel::Functions::Min.new([1, 2, 3]))).to be(false)
    end

    it 'returns distributive? for other binary expressions' do
      expression = described_class.new('+', 0, 0)
      expect(expression).to receive(:distributive?).with('-').and_return(false)
      expect(expression.send(:wrap_value?, described_class.new('-', 0, 0))).to be(false)
    end
  end

  describe 'format_value' do
    it 'works with unresolve cell references' do
      expression = described_class.new('+', a1_reference, sheet.cell_ref(:not, :found))
      expect(expression.send(:format_value, sheet.cell_ref(:not, :found), on_sheet: sheet.name)).to eq('0')
      expect(expression.format(on_sheet: sheet.name)).to eq('A1+0')
    end
  end

  describe 'format' do
    it 'works with a complex example' do
      left_expression = a1_reference * (1 + b1_reference)
      right_expression = Zaxcel::Functions.min(a1_reference, b1_reference) / 2
      expression = described_class.new('<>', left_expression, right_expression)
      expect(expression.format(on_sheet: sheet.name)).to eq('A1*(1+B1)<>MIN(A1,B1)/2')
    end
  end
end
