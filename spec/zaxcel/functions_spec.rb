# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions do
  let(:document) { Zaxcel::Document.new }
  let(:sheet) { document.add_sheet!('Test') }

  before do
    sheet.add_column!(:value)
  end

  describe 'SUM' do
    it 'creates a sum formula' do
      row1 = sheet.add_row!(:row1).add!(:value, value: 10)
      row2 = sheet.add_row!(:row2).add!(:value, value: 20)

      sum = described_class.sum(row1.ref(:value), row2.ref(:value))
      expect(sum).to be_a(Zaxcel::CellFormula)
    end
  end

  describe 'ROUND' do
    it 'creates a round formula' do
      row1 = sheet.add_row!(:row1).add!(:value, value: 10.567)

      rounded = described_class.round(row1.ref(:value), precision: 2)
      expect(rounded).to be_a(Zaxcel::CellFormula)
    end
  end

  describe 'IF' do
    it 'creates an if formula' do
      sheet.add_row!(:row1).add!(:value, value: 100)

      condition = Zaxcel::Functions::If.new(true, if_true: 'High', if_false: 'Low')
      expect(condition).to be_a(Zaxcel::Functions::If)
    end
  end

  describe 'MAX and MIN' do
    it 'creates max formula' do
      row1 = sheet.add_row!(:row1).add!(:value, value: 10)
      row2 = sheet.add_row!(:row2).add!(:value, value: 20)

      max = Zaxcel::Functions::Max.new([row1.ref(:value), row2.ref(:value)])
      expect(max).to be_a(Zaxcel::Functions::Max)
    end

    it 'creates min formula' do
      row1 = sheet.add_row!(:row1).add!(:value, value: 10)
      row2 = sheet.add_row!(:row2).add!(:value, value: 20)

      min = Zaxcel::Functions::Min.new([row1.ref(:value), row2.ref(:value)])
      expect(min).to be_a(Zaxcel::Functions::Min)
    end
  end

  describe 'AVERAGE' do
    it 'creates an average formula' do
      row1 = sheet.add_row!(:row1).add!(:value, value: 10)
      row2 = sheet.add_row!(:row2).add!(:value, value: 20)

      range = Zaxcel::Lang.range(row1.ref(:value), row2.ref(:value))
      avg = described_class.average(range)
      expect(avg).to be_a(Zaxcel::Functions::Average)
    end
  end
end
