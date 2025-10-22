# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Concatenate < Zaxcel::Function
  extend T::Sig

  sig { params(values: T::Array[Zaxcel::Cell::ValueType]).void }
  def initialize(values)
    @values = values
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_values = @values.map do |value|
      Zaxcel::Cell.format(value, on_sheet: on_sheet)
    end

    "CONCATENATE(#{formatted_values.join(',')})"
  end
end
