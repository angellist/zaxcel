# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::SumIf do
  let(:sheet) do
    doc = Zaxcel::Document.new
    sheet = doc.add_sheet!('sum_ifs')

    sheet.add_column!(:values_to_sum)
    sheet.add_column!(:check_one)
    sheet.add_column!(:references)
    sheet.add_row!(:criteria)

    sheet
  end

  before do
    sheet.position_rows!
  end

  it 'works on intra-sheet column ranges' do
    sum_if = described_class.new(
      range_to_check: Zaxcel::Lang.range(sheet.column_ref(:check_one)),
      value_to_check: Zaxcel::Lang.range(sheet.column_ref(:references)),
      range_to_sum: Zaxcel::Lang.range(sheet.column_ref(:values_to_sum)),
    )
    expect(sum_if.format(on_sheet: sheet.name)).to eq('SUMIF(B:B,C:C,A:A)')
  end
end
