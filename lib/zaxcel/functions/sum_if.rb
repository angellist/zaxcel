# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::SumIf < Zaxcel::Function
  extend T::Sig

  sig { params(range_to_check: Zaxcel::References::Range, value_to_check: Zaxcel::Cell::ValueType, range_to_sum: Zaxcel::References::Range).void }
  def initialize(range_to_check:, value_to_check:, range_to_sum:)
    raise 'Column to check and column to sum must be on the same sheet!' if range_to_check.sheet_name != range_to_sum.sheet_name

    @range_to_check = range_to_check
    @value_to_check = value_to_check
    @range_to_sum = range_to_sum
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "SUMIF(#{@range_to_check.format(on_sheet: on_sheet)},#{Zaxcel::Cell.format(@value_to_check, on_sheet: on_sheet)},#{@range_to_sum.format(on_sheet: on_sheet)})"
  end
end
