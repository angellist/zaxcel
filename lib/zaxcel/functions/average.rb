# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Average < Zaxcel::Function
  extend T::Sig

  # todo - match this to the excel signature if it takes an unbounded argument array
  sig { params(range: Zaxcel::References::Range).void }
  def initialize(range)
    @range = range
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "AVERAGE(#{@range.format(on_sheet: on_sheet)})"
  end
end
