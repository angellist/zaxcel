# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Max < Zaxcel::Function
  extend T::Sig

  sig { params(values: T::Array[T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)]).void }
  def initialize(values)
    @values = values
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_values = @values.map { |value| Zaxcel::Cell.format(value, on_sheet: on_sheet) }.compact
    "MAX(#{formatted_values.join(',')})"
  end
end
