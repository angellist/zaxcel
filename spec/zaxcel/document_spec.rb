# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Document do
  describe '#initialize' do
    it 'creates a new document' do
      document = described_class.new
      expect(document).to be_a(described_class)
    end

    it 'sets width units by default character' do
      document = described_class.new(width_units_by_default_character: 1.0)
      expect(document.width_units_by_default_character).to eq(1.0)
    end
  end

  describe '#add_sheet!' do
    let(:document) { described_class.new }

    it 'adds a sheet to the document' do
      sheet = document.add_sheet!('Test Sheet')
      expect(sheet).to be_a(Zaxcel::Sheet)
      expect(sheet.name).to eq('Test Sheet')
    end

    it 'returns the same sheet when accessed by name' do
      sheet = document.add_sheet!('Test Sheet')
      expect(document.sheet('Test Sheet')).to eq(sheet)
    end

    it 'cleans sheet names longer than 31 characters' do
      long_name = 'A' * 40
      sheet = document.add_sheet!(long_name)
      expect(sheet.to_excel.length).to be <= Zaxcel::Document::MAX_SHEET_NAME_LENGTH
    end

    it 'creates unique names for duplicate sheets' do
      sheet1 = document.add_sheet!('Duplicate')
      sheet2 = document.add_sheet!('Duplicate')
      expect(sheet1.to_excel).to start_with('Duplicate')
      expect(sheet2.to_excel).to match(/Duplicat\d+/)
    end

    it 'supports hidden sheets' do
      sheet = document.add_sheet!('Hidden', sheet_visibility: Zaxcel::Sheet::SheetVisibility::Hidden)
      # Apply visibility directly without generating the sheet
      sheet.apply_sheet_visibility!
      expect(sheet.unsafe_axlsx_worksheet.state).to eq(:hidden)
    end
  end

  describe '#add_style!' do
    let(:document) { described_class.new }

    it 'adds a style and returns style index' do
      style_index = document.add_style!(:test_style, bg_color: 'FF0000')
      expect(style_index).to be_a(Integer)
    end

    it 'returns the same style index for the same name' do
      index1 = document.add_style!(:test_style, bg_color: 'FF0000')
      index2 = document.add_style!(:test_style, bg_color: '00FF00')
      expect(index1).to eq(index2)
    end
  end

  describe '#file_contents' do
    let(:document) { described_class.new }

    it 'returns binary content even for an empty document' do
      contents = document.file_contents
      expect(contents).to be_a(String)
      expect(contents.encoding).to eq(Encoding::ASCII_8BIT)
      expect(contents).not_to be_empty
    end

    it 'returns binary content after generating sheets' do
      sheet = document.add_sheet!('Test')
      sheet.add_column!(:col1)
      sheet.add_row!(:row1).add!(:col1, value: 'Test')
      # Do not call generate_sheet!; content should still be present
      contents = document.file_contents
      expect(contents).to be_a(String)
      expect(contents.encoding).to eq(Encoding::ASCII_8BIT)
      expect(contents).not_to be_empty
    end
  end

  describe 'integration test' do
    it 'creates a complete spreadsheet with formulas' do
      document = described_class.new
      sheet = document.add_sheet!('Sales')

      # Add columns
      sheet.add_column!(:product)
      sheet.add_column!(:price)
      sheet.add_column!(:quantity)
      sheet.add_column!(:total)

      # Add header row
      document.add_style!(:header, b: true, bg_color: 'CCCCCC')
      sheet.add_row!(:header)
        .add!(:product, value: 'Product')
        .add!(:price, value: 'Price')
        .add!(:quantity, value: 'Quantity')
        .add!(:total, value: 'Total')

      # Add data rows
      row1 = sheet.add_row!(:item1)
        .add!(:product, value: 'Widget')
        .add!(:price, value: 10.00)
        .add!(:quantity, value: 5)

      # Add formula for total
      row1.add!(:total, value: row1.ref(:price) * row1.ref(:quantity))

      row2 = sheet.add_row!(:item2)
        .add!(:product, value: 'Gadget')
        .add!(:price, value: 20.00)
        .add!(:quantity, value: 3)
      row2.add!(:total, value: row2.ref(:price) * row2.ref(:quantity))

      # Add total row with sum
      sheet.add_row!(:grand_total)
        .add!(:product, value: 'TOTAL')
        .add!(:price, value: nil)
        .add!(:quantity, value: nil)
        .add!(:total, value: row1.ref(:total) + row2.ref(:total))

      # Do not call generate_sheet!; content should still be present
      contents = document.file_contents
      expect(contents).to be_a(String)
      expect(contents).not_to be_empty
    end
  end
end
