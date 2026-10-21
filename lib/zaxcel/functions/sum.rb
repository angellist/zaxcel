# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Sum < Zaxcel::Function
  extend T::Sig

  MAX_FUNCTION_ARGS = Zaxcel::Functions::RangeCoalescing::MAX_FUNCTION_ARGS

  sig { params(values: T::Array[T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)]).void }
  def initialize(values)
    @values = values
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    return '0' if @values.blank?

    args = @values.map { |value| Zaxcel::Cell.format(value, on_sheet: on_sheet).to_s }
    args = Zaxcel::Functions::RangeCoalescing.coalesce(args)
    "SUM(#{args.join(',')})"
  end
end
