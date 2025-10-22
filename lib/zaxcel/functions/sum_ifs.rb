# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::SumIfs < Zaxcel::Function
  extend T::Sig

  sig do
    params(
      ranges_to_check: T::Array[Zaxcel::References::Range],
      values_to_check: T::Array[Zaxcel::Cell::ValueType],
      range_to_sum: Zaxcel::References::Range,
    ).void
  end
  def initialize(ranges_to_check:, values_to_check:, range_to_sum:)
    raise 'Columns to check and values to check must be the same length' if ranges_to_check.count != values_to_check.count

    @ranges_to_check = ranges_to_check
    @values_to_check = values_to_check
    @range_to_sum = range_to_sum
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    criteria = @ranges_to_check.flat_map.with_index do |check_range, index|
      check_value = @values_to_check[index]
      [
        check_range.format(on_sheet: on_sheet),
        Zaxcel::Cell.format(check_value, on_sheet: on_sheet, quote_strings: false),
      ]
    end

    "SUMIFS(#{@range_to_sum.format(on_sheet: on_sheet)},#{criteria.join(',')})"
  end
end
