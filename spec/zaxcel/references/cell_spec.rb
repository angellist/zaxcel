# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::References::Cell do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('cell_references')

    calc_sheet.add_column!(:yep_column)
    calc_sheet.add_row!(:yep_row)

    calc_sheet
  end

  it 'sheet exists no column' do
    expect(sheet.cell_ref(:nope, :yep_row).format(on_sheet: nil)).to be_nil
  end

  it 'sheet exists no row' do
    expect(sheet.cell_ref(:yep_column, :nope).format(on_sheet: nil)).to be_nil
  end

  it 'no value' do
    expect(sheet.cell_ref(:yep_column, :yep_row).format(on_sheet: nil)).to be_nil
  end
end
