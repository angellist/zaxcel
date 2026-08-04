# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'zip'
require 'stringio'

RSpec.describe Zaxcel::Functions::Sum do
  describe '#format' do
    let(:sheet) do
      doc = Zaxcel::Document.new
      sheet = doc.add_sheet!('realizations')
      amount = sheet.add_column!(:amount)
      (1..260).each do |i|
        row = sheet.add_row!(:"r#{i}")
        amount.add_cell!(row: row, value: i)
      end
      sheet
    end

    before { sheet.position_rows! }

    def amount_refs(rows)
      rows.map { |i| sheet.cell_ref(:amount, :"r#{i}") }
    end

    it 'renders an enumerated SUM at or below Excel argument limit' do
      refs = amount_refs(1..3)
      expected = "SUM(#{refs.map { |r| r.format(on_sheet: sheet.name) }.join(',')})"
      expect(described_class.new(refs).format(on_sheet: sheet.name)).to eq(expected)
    end

    it 'collapses a contiguous column of more than 255 cells into a single range' do
      refs = amount_refs(1..260)
      first = sheet.cell_ref(:amount, :r1).format(on_sheet: sheet.name)
      last = sheet.cell_ref(:amount, :r260).format(on_sheet: sheet.name)
      expect(described_class.new(refs).format(on_sheet: sheet.name)).to eq("SUM(#{first}:#{last})")
    end

    it 'renders 0 when empty' do
      expect(described_class.new([]).format(on_sheet: sheet.name)).to eq('0')
    end
  end

  # End-to-end: serialize a workbook to .xlsx and read the formulas back from the worksheet XML.
  describe 'rendered workbook' do
    def sheet_formulas(document, part: 'xl/worksheets/sheet1.xml')
      Zip::File.open_buffer(StringIO.new(document.file_contents)) do |zip|
        xml = zip.get_entry(part).get_input_stream.read
        return xml.scan(%r{<f[^>]*>(.*?)</f>}m).flatten
                  .map { |f| f.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>') }
      end
    end

    def max_function_args(formulas)
      formulas.flat_map { |f| f.scan(/SUM\(([^()]*)\)/).map { |inner| inner[0].split(',').size } }.max
    end

    it 'writes a contiguous column total as one range and keeps the file within Excel limits' do
      document = Zaxcel::Document.new
      sheet = document.add_sheet!('Realizations')
      sheet.add_column!(:amount)
      refs = (1..260).map { |i| sheet.add_row!(:"r#{i}").add!(:amount, value: i).ref(:amount) }
      sheet.add_row!(:total).add!(:amount, value: Zaxcel::Functions.sum(*refs))
      sheet.position_rows!
      sheet.generate_sheet!

      formulas = sheet_formulas(document)
      expect(formulas).to include('SUM(A1:A260)')
      expect(max_function_args(formulas)).to be <= described_class::MAX_FUNCTION_ARGS
    end

    it 'writes an enumerated total below the limit' do
      document = Zaxcel::Document.new
      sheet = document.add_sheet!('Realizations')
      sheet.add_column!(:amount)
      refs = (1..3).map { |i| sheet.add_row!(:"r#{i}").add!(:amount, value: i).ref(:amount) }
      sheet.add_row!(:total).add!(:amount, value: Zaxcel::Functions.sum(*refs))
      sheet.position_rows!
      sheet.generate_sheet!

      expect(sheet_formulas(document)).to include('SUM(A1,A2,A3)')
    end
  end
end
