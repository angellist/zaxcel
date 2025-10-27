# frozen_string_literal: true
# typed: strict

class Zaxcel::BinaryExpression < Zaxcel::CellFormula
  extend T::Sig

  sig { returns(String) }
  attr_reader :operator

  sig do
    params(
      operator: String,
      lh_value: Zaxcel::Cell::ValueType,
      rh_value: Zaxcel::Cell::ValueType,
    ).void
  end
  def initialize(operator, lh_value, rh_value)
    @operator = operator
    @lh_value = lh_value
    @rh_value = rh_value
  end

  sig { override.params(on_sheet: String).returns(T.nilable(T.any(Numeric, Money, String))) }
  def format(on_sheet:)
    formatted_lh_value = format_value(@lh_value, on_sheet: on_sheet)
    formatted_rh_value = format_value(@rh_value, on_sheet: on_sheet)

    "#{formatted_lh_value}#{@operator}#{formatted_rh_value}"
  end

  private

  sig do
    params(
      value: Zaxcel::Cell::ValueType,
      on_sheet: String,
    ).returns(T.any(Numeric, Money, String))
  end
  def format_value(value, on_sheet:)
    base_format = Zaxcel::Cell.format(value, on_sheet: on_sheet)
    # If a cell reference doesn't resolve, we want to handle it gracefully and not produce bad formulas. If we just
    # print an empty string, we will get a bad formula, so instead swap for zero, since it is reasonable to assume that
    # if a cell does not exist, its value is zero.
    # In the future, we might consider adding a default behavior of erroring on missing cell references, with the
    # ability to add an if_error formula which replaces a nil cell reference with a default value.
    return '0' if base_format.nil?

    base_format = "(#{base_format})" if wrap_value?(value)
    base_format
  end

  # Operators don't always associate with each other nicely with parentheses. For instance,
  #   3 * (1 + 2) != 3 * 1 + 2,
  # so we need some rules around when to wrap in parens when the left or right hand value have operators.
  # The general rules are:
  # 1. When it's a basic value or a reference, such as string or number, don't wrap, e.g. "hello", 1, or A1:B1.
  # 2. When it's a function, don't wrap since the function is a single token, e.g. SUM(...), MIN(...), or ROUND(...).
  # 3. When it's a binary expression, wrap if the operator distributes over the inner operator.
  #    https://en.wikipedia.org/wiki/Distributive_property
  sig { params(value: Zaxcel::Cell::ValueType).returns(T::Boolean) }
  def wrap_value?(value)
    return false if !value.is_a?(Zaxcel::CellFormula)
    return true if value.is_a?(Zaxcel::Functions::Negate)
    return false if value.is_a?(Zaxcel::Function)
    return distributive?(value.operator) if value.is_a?(Zaxcel::BinaryExpression)

    true
  end

  sig { overridable.params(inner_operator: String).returns(T::Boolean) }
  def distributive?(inner_operator)
    false
  end
end
