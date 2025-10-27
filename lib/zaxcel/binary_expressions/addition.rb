# frozen_string_literal: true
# typed: strict

class Zaxcel::BinaryExpressions::Addition < Zaxcel::BinaryExpression
  extend T::Sig

  sig do
    params(
      lh_value: Zaxcel::Cell::ValueType,
      rh_value: Zaxcel::Cell::ValueType,
    ).void
  end
  def initialize(lh_value, rh_value)
    super('+', lh_value, rh_value)
  end

  sig { override.params(on_sheet: String).returns(T.nilable(T.any(Numeric, Money, String))) }
  def format(on_sheet:)
    # Don't call `format_value` here to avoid wrapping in parens, which is unnecessary.
    if @lh_value.is_a?(Zaxcel::Arithmetic::CoercedValue) && @lh_value.additive_identity?
      return Zaxcel::Cell.format(@rh_value, on_sheet: on_sheet)
    elsif @rh_value.is_a?(Zaxcel::Arithmetic::CoercedValue) && @rh_value.additive_identity?
      return Zaxcel::Cell.format(@lh_value, on_sheet: on_sheet)
    end

    super
  end

  private

  # sum never distributes over anything (other things distribute over it)
  sig { override.params(inner_operator: String).returns(T::Boolean) }
  def distributive?(inner_operator)
    false
  end
end
