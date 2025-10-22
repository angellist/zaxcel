# frozen_string_literal: true
# typed: strict

module Zaxcel::Lang
  class << self
    extend T::Sig

    sig { params(condition: Zaxcel::Cell::ValueType).returns(Zaxcel::IfBuilder) }
    def if(condition)
      Zaxcel::IfBuilder.new(condition)
    end

    sig do
      params(
        lh_value: Zaxcel::References::Range::RangeableType,
        rh_value: T.nilable(Zaxcel::References::Range::RangeableType),
      ).returns(Zaxcel::References::Range)
    end
    def range(lh_value, rh_value = nil)
      Zaxcel::References::Range.new(lh_value, rh_value)
    end
  end
end
