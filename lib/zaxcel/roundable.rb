# frozen_string_literal: true
# typed: strict

module Zaxcel::Roundable
  extend T::Sig
  extend T::Helpers

  requires_ancestor { Zaxcel::Arithmetic }

  sig { params(precision: Integer).returns(Zaxcel::Functions::Round) }
  def round(precision: 0)
    Zaxcel::Functions::Round.new(T.bind(self, Zaxcel::Arithmetic), precision: precision)
  end
end
