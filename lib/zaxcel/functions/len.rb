# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Len < Zaxcel::Function
  extend T::Sig

  sig { params(value: Zaxcel::Cell::ValueType).void }
  def initialize(value)
    @value = value
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "LEN(#{Zaxcel::Cell.format(@value, on_sheet: on_sheet)})"
  end
end
