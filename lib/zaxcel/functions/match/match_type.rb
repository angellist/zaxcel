# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Match::MatchType < T::Enum
  enums do
    # Finds the first value exactly equal to lookup_value. lookup_array can be in any order.
    EXACT = new('0')
    # Finds the largest value less than or equal to lookup_value. Requires lookup_array to be in ascending order.
    LESS_THAN_OR_EQUAL = new('1')
    # Finds the smallest value greater than or equal to lookup_value. Requires lookup_array to be in descending order.
    GREATER_THAN_OR_EQUAL = new('-1')
  end
end
