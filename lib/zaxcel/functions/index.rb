# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Index < Zaxcel::Function
  sig do
    params(
      index_value: Zaxcel::Cell::ValueType,
      range: Zaxcel::References::Range,
    ).void
  end
  def initialize(index_value:, range:)
    @index_value = index_value
    @range = range
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "INDEX(#{@range.format(on_sheet: on_sheet)},#{Zaxcel::Cell.format(@index_value, on_sheet: on_sheet)})"
  end
end
