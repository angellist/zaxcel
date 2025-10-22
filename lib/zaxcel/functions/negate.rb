# frozen_string_literal: true
# typed: strict

# This isn't really a function, it's a unary operator, so this is in the wrong spot. But I'm not sure where the best
# place for it is yet, so just leave it here for now.
class Zaxcel::Functions::Negate < Zaxcel::CellFormula
  extend T::Sig

  sig { params(value: Zaxcel::Cell::ValueType).void }
  def initialize(value)
    @value = value
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_value = Zaxcel::Cell.format(@value, on_sheet: on_sheet)
    return '0' if formatted_value.nil? && @value.is_a?(Zaxcel::References::Cell)

    formatted_value = "(#{formatted_value})" if @value.is_a?(Zaxcel::BinaryExpression) && ['-',
                                                                                           '+'].include?(@value.operator)

    "-#{formatted_value}"
  end
end
