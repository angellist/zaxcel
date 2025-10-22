# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::XLookup < Zaxcel::Function
  extend T::Sig

  sig do
    params(
      condition: Zaxcel::Cell::ValueType,
      idx_range: Zaxcel::References::Range,
      value_range: Zaxcel::References::Range,
    ).void
  end
  def initialize(condition, idx_range:, value_range:)
    @condition = condition
    @idx_range = idx_range
    @value_range = value_range
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_condition = Zaxcel::Cell.format(@condition, on_sheet: on_sheet)
    formatted_idx_range = @idx_range.format(on_sheet: on_sheet)
    formatted_value_range = @value_range.format(on_sheet: on_sheet)

    "XLOOKUP(#{formatted_condition},#{formatted_idx_range},#{formatted_value_range})"
  end
end
