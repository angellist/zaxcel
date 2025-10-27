# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::SumIfs do
  NUM_CRITERIA_VALUES = 10

  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('sum_ifs')

    calc_sheet.add_column!(:values_to_sum)
    calc_sheet.add_column!(:check_one)
    calc_sheet.add_column!(:check_two)
    calc_sheet.add_column!(:references)

    calc_sheet.add_row!(:criteria)
      .add!(:references, value: 0)

    NUM_CRITERIA_VALUES.times { |i| calc_sheet.add_row!("criteria_#{i}").add!(:check_one, value: i).add!(:check_two, value: i) }

    calc_sheet
  end

  let(:check_one_range) do
    column = sheet.column(:check_one)
    Zaxcel::Lang.range(column.ref(:criteria_0), column.ref(:criteria_9))
  end

  let(:check_two_range) do
    column = sheet.column(:check_two)
    Zaxcel::Lang.range(column.ref(:criteria_0), column.ref(:criteria_9))
  end

  it 'works on intra-sheet column ranges' do
    sum_range = Zaxcel::Lang.range(sheet.column_ref(:values_to_sum))
    check_ranges = [:check_one, :check_two].map { |col_sym| Zaxcel::Lang.range(sheet.column_ref(col_sym)) }
    check_values = [0, sheet.column(:references).ref(:criteria)]

    sum_ifs = described_class.new(ranges_to_check: check_ranges, values_to_check: check_values, range_to_sum: sum_range)
    sheet.position_rows!
    expect(sum_ifs.format(on_sheet: sheet.name)).to eq('SUMIFS(A:A,B:B,0,C:C,D1)')
  end

  it 'works on inter-sheet column ranges' do
    sum_range = Zaxcel::Lang.range(sheet.column_ref(:values_to_sum))
    check_ranges = [:check_one, :check_two].map { |col_sym| Zaxcel::Lang.range(sheet.column_ref(col_sym)) }
    check_values = [0, sheet.column(:references).ref(:criteria)]

    sum_ifs = described_class.new(ranges_to_check: check_ranges, values_to_check: check_values, range_to_sum: sum_range)
    sheet.position_rows!
    expect(sum_ifs.format(on_sheet: 'other')).to eq("SUMIFS('sum_ifs'!A:A,'sum_ifs'!B:B,0,'sum_ifs'!C:C,'sum_ifs'!D1)")
  end

  it 'works on intra-sheet column cell ranges' do
    sum_range = Zaxcel::Lang.range(sheet.column_ref(:values_to_sum))
    check_ranges = [check_one_range, check_two_range]
    check_values = [0, sheet.column(:references).ref(:criteria)]

    sum_ifs = described_class.new(ranges_to_check: check_ranges, values_to_check: check_values, range_to_sum: sum_range)
    sheet.position_rows!
    expect(sum_ifs.format(on_sheet: sheet.name)).to eq('SUMIFS(A:A,B2:B11,0,C2:C11,D1)')
  end

  it 'works on inter-sheet column cell ranges' do
    sum_range = Zaxcel::Lang.range(sheet.column_ref(:values_to_sum))
    check_ranges = [check_one_range, check_two_range]
    check_values = [0, sheet.column(:references).ref(:criteria)]

    sum_ifs = described_class.new(ranges_to_check: check_ranges, values_to_check: check_values, range_to_sum: sum_range)
    sheet.position_rows!
    expect(sum_ifs.format(on_sheet: 'other')).to eq("SUMIFS('sum_ifs'!A:A,'sum_ifs'!B2:B11,0,'sum_ifs'!C2:C11,'sum_ifs'!D1)")
  end

  it 'support conditional criteria' do
    sum_range = Zaxcel::Lang.range(sheet.column_ref(:values_to_sum))
    check_ranges = [:check_one, :check_two].map { |col_sym| Zaxcel::Lang.range(sheet.column_ref(col_sym)) }
    check_values = ['"<"&DATE(2024, 9, 30)+TIME(23, 59, 59)', '"<>MR_ED"']

    sum_ifs = described_class.new(ranges_to_check: check_ranges, values_to_check: check_values, range_to_sum: sum_range)
    sheet.position_rows!
    expect(sum_ifs.format(on_sheet: sheet.name)).to eq('SUMIFS(A:A,B:B,"<"&DATE(2024, 9, 30)+TIME(23, 59, 59),C:C,"<>MR_ED")')
  end
end
