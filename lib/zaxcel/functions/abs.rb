# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Abs < Zaxcel::Function
  extend T::Sig

  sig { params(value: Zaxcel::Cell::ValueType).void }
  def initialize(value)
    @value = value
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_value = Zaxcel::Cell.format(@value, on_sheet: on_sheet) || 0

    "ABS(#{formatted_value})"
  end
end
