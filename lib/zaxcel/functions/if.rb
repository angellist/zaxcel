# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::If < Zaxcel::Function
  extend T::Sig

  # access to 'clauses' can be helpful if debugging
  sig { returns(Zaxcel::Cell::ValueType) }
  attr_reader :condition

  sig { returns(Zaxcel::Cell::ValueType) }
  attr_reader :if_true

  sig { returns(Zaxcel::Cell::ValueType) }
  attr_reader :if_false

  sig do
    params(
      condition: Zaxcel::Cell::ValueType,
      if_true: Zaxcel::Cell::ValueType,
      if_false: Zaxcel::Cell::ValueType,
    ).void
  end
  def initialize(condition, if_true:, if_false:)
    @condition = condition
    @if_true = if_true
    @if_false = if_false
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    formatted_condition = Zaxcel::Cell.format(@condition, on_sheet: on_sheet)
    formatted_if_true = Zaxcel::Cell.format(@if_true, on_sheet: on_sheet)
    formatted_if_false = Zaxcel::Cell.format(@if_false, on_sheet: on_sheet)

    "IF(#{formatted_condition},#{formatted_if_true},#{formatted_if_false})"
  end
end
