# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Round < Zaxcel::Function
  extend T::Sig

  sig { params(value: Zaxcel::Cell::ValueType, precision: Integer).void }
  def initialize(value, precision: 0)
    @value = value
    @precision = precision
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_value = Zaxcel::Cell.format(@value, on_sheet: on_sheet)
    return '0' if formatted_value.nil? && @value.is_a?(Zaxcel::References::Cell)

    "ROUND(#{formatted_value},#{@precision})"
  end
end
