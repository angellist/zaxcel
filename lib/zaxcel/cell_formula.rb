# frozen_string_literal: true
# typed: strict

class Zaxcel::CellFormula
  extend T::Sig
  extend T::Helpers
  include Zaxcel::Arithmetic
  include Zaxcel::Roundable

  abstract!

  EXCEL_EPOCH = Date.new(1900, 1, 1)

  sig { abstract.params(on_sheet: String).returns(T.nilable(T.any(Numeric, Money, String))) }
  def format(on_sheet:); end
end
