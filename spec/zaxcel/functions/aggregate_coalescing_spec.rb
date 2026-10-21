# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'zip'
require 'stringio'

[Zaxcel::Functions::Sum, Zaxcel::Functions::Min, Zaxcel::Functions::Max].each do |aggregate|
  RSpec.describe aggregate do
    let(:function_name) { described_class.name.split('::').last.upcase }
    let(:document) { Zaxcel::Document.new }
    let(:sheet) { document.add_sheet!('Data') }
    let(:refs) do
      sheet.add_column!(:amount)
      (1..260).map do |i|
        sheet.add_row!(:"r#{i}").add!(:amount, value: i).ref(:amount)
      end
    end

    def format_values(values, on_sheet: 'Data')
      sheet.position_rows!
      described_class.new(values).format(on_sheet: on_sheet)
    end

    it 'keeps exactly 255 references enumerated' do
      expected = (1..255).map { |i| "A#{i}" }.join(',')
      expect(format_values(refs.first(255))).to eq("#{function_name}(#{expected})")
    end

    it 'coalesces at 256 references' do
      expect(format_values(refs.first(256))).to eq("#{function_name}(A1:A256)")
    end

    it 'preserves gaps, duplicates and literals around coalesced runs' do
      values = [refs[0], refs[1], refs[1], refs[2], 42, *refs[4..]]
      expect(format_values(values)).to eq("#{function_name}(A1:A2,A2:A3,42,A5:A260)")
    end

    it 'leaves cross-sheet references unchanged even above the limit' do
      values = refs
      sheet.position_rows!
      expected = values.map { |ref| ref.format(on_sheet: 'Summary') }.join(',')
      expect(format_values(values, on_sheet: 'Summary')).to eq("#{function_name}(#{expected})")
    end

    it 'writes the coalesced formula into the workbook' do
      formula = described_class.new(refs)
      sheet.add_row!(:total).add!(:amount, value: formula)
      sheet.position_rows!
      sheet.generate_sheet!

      Zip::File.open_buffer(StringIO.new(document.file_contents)) do |zip|
        xml = zip.get_entry('xl/worksheets/sheet1.xml').get_input_stream.read
        formulas = xml.scan(%r{<f[^>]*>(.*?)</f>}m).flatten
        expect(formulas).to include("#{function_name}(A1:A260)")
      end
    end

    unless aggregate == Zaxcel::Functions::Sum
      it 'counts arguments after omitting unresolved references' do
        values = refs.first(255) + [sheet.cell_ref(:amount, :missing)]
        expected = (1..255).map { |i| "A#{i}" }.join(',')
        expect(format_values(values)).to eq("#{function_name}(#{expected})")
      end

      it 'preserves empty input behavior' do
        expect(format_values([])).to eq("#{function_name}()")
      end
    end
  end
end
