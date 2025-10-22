# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Text < Zaxcel::Function
  extend T::Sig

  sig { params(value: Zaxcel::Cell::ValueType, format_string: String).void }
  def initialize(value, format_string:)
    @value = value
    @format_string = format_string
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "TEXT(#{Zaxcel::Cell.format(@value, on_sheet: on_sheet)},#{Zaxcel::Cell.format(@format_string, on_sheet: on_sheet)})"
  end
end
