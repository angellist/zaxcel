# frozen_string_literal: true
# typed: strict

class Zaxcel::BinaryExpressions::Division < Zaxcel::BinaryExpression
  extend T::Sig

  sig do
    params(
      lh_value: Zaxcel::Cell::ValueType,
      rh_value: Zaxcel::Cell::ValueType
    ).void
  end
  def initialize(lh_value, rh_value)
    super('/', lh_value, rh_value)
  end

  private

  # division distributes over addition / subtraction
  sig { override.params(inner_operator: String).returns(T::Boolean) }
  def distributive?(inner_operator)
    ['+', '-'].include?(inner_operator)
  end
end
