# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::IfError < Zaxcel::Function
  extend T::Sig

  sig do
    params(
      value: Zaxcel::Cell::ValueType,
      default_value: Zaxcel::Cell::ValueType,
    ).void
  end
  def initialize(value, default_value:)
    @value = value
    @default_value = default_value
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_value = Zaxcel::Cell.format(@value, on_sheet: on_sheet)
    formatted_default = Zaxcel::Cell.format(@default_value, on_sheet: on_sheet)

    "IFERROR(#{formatted_value},#{formatted_default})"
  end
end
