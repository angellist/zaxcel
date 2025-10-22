# frozen_string_literal: true
# typed: strict

module Zaxcel::BinaryExpressions
  class << self
    extend T::Sig

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def less_than(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('<', lh_value, rh_value)
    end

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def less_than_equal(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('<=', lh_value, rh_value)
    end

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def greater_than(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('>', lh_value, rh_value)
    end

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def greater_than_equal(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('>=', lh_value, rh_value)
    end

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def equal(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('=', lh_value, rh_value)
    end

    sig { params(lh_value: Zaxcel::Cell::ValueType, rh_value: Zaxcel::Cell::ValueType).returns(Zaxcel::BinaryExpression) }
    def not_equal(lh_value, rh_value)
      Zaxcel::BinaryExpression.new('<>', lh_value, rh_value)
    end
  end
end
