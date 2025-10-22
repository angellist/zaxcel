# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Or < Zaxcel::Function
  extend T::Sig

  # todo - likely and can accept more than one arg, but not sure. check into this.
  # also, it may accept only specific types of formulas (returns true or false or something), but my suspicion is that
  # is not true. confirm this also, since right now it's typed to a strange type.
  sig { params(left_hand_value: Zaxcel::Cell::ValueType, right_hand_value: Zaxcel::Cell::ValueType).void }
  def initialize(left_hand_value, right_hand_value)
    @left_hand_value = left_hand_value
    @right_hand_value = right_hand_value
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    left_hand_formatted_value = Zaxcel::Cell.format(@left_hand_value, on_sheet: on_sheet)
    right_hand_formatted_value = Zaxcel::Cell.format(@right_hand_value, on_sheet: on_sheet)

    "OR(#{left_hand_formatted_value},#{right_hand_formatted_value})"
  end
end
