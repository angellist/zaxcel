# frozen_string_literal: true
# typed: strict

module Zaxcel::Functions
  class << self
    extend T::Sig

    sig { params(value: Zaxcel::Cell::ValueType).returns(Zaxcel::Functions::Abs) }
    def abs(value)
      Zaxcel::Functions::Abs.new(value)
    end

    sig do
      params(
        lh_value: Zaxcel::Cell::ValueType,
        rh_value: Zaxcel::Cell::ValueType,
      ).returns(Zaxcel::Functions::And)
    end
    def and(lh_value, rh_value)
      Zaxcel::Functions::And.new(lh_value, rh_value)
    end

    sig { params(range: Zaxcel::References::Range).returns(Zaxcel::Functions::Average) }
    def average(range)
      Zaxcel::Functions::Average.new(range)
    end

    sig { params(values: Zaxcel::Cell::ValueType).returns(Zaxcel::Functions::Concatenate) }
    def concatenate(*values)
      Zaxcel::Functions::Concatenate.new(values)
    end

    sig do
      params(
        choice_index: Zaxcel::Cell::ValueType,
        choices: T::Array[Zaxcel::Cell::ValueType],
      ).returns(Zaxcel::Functions::Choose)
    end
    def choose(choice_index, choices:)
      Zaxcel::Functions::Choose.new(choice_index, choices: choices)
    end

    sig do
      params(
        value: Zaxcel::Cell::ValueType,
        default_value: Zaxcel::Cell::ValueType,
      ).returns(Zaxcel::Functions::IfError)
    end
    def if_error(value, default_value:)
      Zaxcel::Functions::IfError.new(value, default_value: default_value)
    end

    sig do
      params(
        index_value: Zaxcel::Cell::ValueType,
        range: Zaxcel::References::Column,
      ).returns(Zaxcel::Functions::Index)
    end
    def index(index_value:, range:)
      Zaxcel::Functions::Index.new(index_value: index_value, range: Zaxcel::Lang.range(range))
    end

    sig { params(value: Zaxcel::Cell::ValueType, range: Zaxcel::References::Column, match_type: T.nilable(Zaxcel::Functions::Match::MatchType)).returns(Zaxcel::Functions::Match) }
    def match(value:, range:, match_type: nil)
      Zaxcel::Functions::Match.new(value: value, range: Zaxcel::Lang.range(range), match_type: match_type)
    end

    sig { params(values: T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)).returns(Zaxcel::Functions::Max) }
    def max(*values)
      Zaxcel::Functions::Max.new(values)
    end

    sig { params(values: T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)).returns(Zaxcel::Functions::Min) }
    def min(*values)
      Zaxcel::Functions::Min.new(values)
    end

    sig do
      params(
        lh_value: Zaxcel::Cell::ValueType,
        rh_value: Zaxcel::Cell::ValueType,
      ).returns(Zaxcel::Functions::Or)
    end
    def or(lh_value, rh_value)
      Zaxcel::Functions::Or.new(lh_value, rh_value)
    end

    sig { params(value: Zaxcel::Cell::ValueType, precision: Integer).returns(Zaxcel::Functions::Round) }
    def round(value, precision: 0)
      Zaxcel::Functions::Round.new(value, precision: precision)
    end

    sig { params(values: T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)).returns(Zaxcel::Functions::Sum) }
    def sum(*values)
      Zaxcel::Functions::Sum.new(values)
    end

    sig do
      params(
        column_to_check: Zaxcel::References::Column,
        value_to_check: Zaxcel::Cell::ValueType,
        column_to_sum: Zaxcel::References::Column,
      ).returns(Zaxcel::Functions::SumIf)
    end
    def sum_if(column_to_check:, value_to_check:, column_to_sum:)
      Zaxcel::Functions::SumIf.new(
        range_to_check: Zaxcel::Lang.range(column_to_check),
        value_to_check: value_to_check,
        range_to_sum: Zaxcel::Lang.range(column_to_sum),
      )
    end

    sig do
      params(
        ranges_to_check: T::Array[Zaxcel::References::Range],
        values_to_check: T::Array[Zaxcel::Cell::ValueType],
        range_to_sum: Zaxcel::References::Range,
      ).returns(Zaxcel::Functions::SumIfs)
    end
    def sum_ifs(ranges_to_check:, values_to_check:, range_to_sum:)
      Zaxcel::Functions::SumIfs.new(
        ranges_to_check: ranges_to_check,
        values_to_check: values_to_check,
        range_to_sum: range_to_sum,
      )
    end

    sig { params(range_values: T::Enumerable[Zaxcel::References::Range::RangeableType]).returns(Zaxcel::Functions::Sum) }
    def sum_range(range_values)
      range = Zaxcel::Lang.range(range_values.first!, range_values.last!) if range_values.any?
      Zaxcel::Functions::Sum.new([range].compact)
    end

    sig { params(value: Zaxcel::Cell::ValueType, format_string: String).returns(Zaxcel::Functions::Text) }
    def text(value, format_string:)
      Zaxcel::Functions::Text.new(value, format_string: format_string)
    end

    sig { params(value: Zaxcel::Cell::ValueType).returns(Zaxcel::Functions::Len) }
    def len(value)
      Zaxcel::Functions::Len.new(value)
    end

    sig do
      params(
        condition: Zaxcel::Cell::ValueType,
        idx_range: Zaxcel::References::Range,
        value_range: Zaxcel::References::Range,
      ).returns(Zaxcel::Functions::XLookup)
    end
    def x_lookup(condition, idx_range:, value_range:)
      Zaxcel::Functions::XLookup.new(condition, idx_range: idx_range, value_range: value_range)
    end

    sig do
      params(
        values: T::Array[Zaxcel::References::Cell],
        dates: T::Array[Zaxcel::References::Cell],
        guess: T.nilable(Zaxcel::CellFormula),
      ).returns(Zaxcel::Functions::Xirr)
    end
    def xirr(values:, dates:, guess: nil)
      value_range = Zaxcel::References::Range.new(values.first!, values.last!)
      date_range = Zaxcel::References::Range.new(dates.first!, dates.last!)

      Zaxcel::Functions::Xirr.new(value_range, date_range, guess: guess)
    end
  end
end
