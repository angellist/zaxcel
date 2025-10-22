# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Unique < Zaxcel::Function
  extend T::Sig

  sig { params(range: Zaxcel::References::Range, array_formula: T::Boolean).void }
  def initialize(range, array_formula: false)
    @range = range
    @array_formula = array_formula
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    "UNIQUE(#{@range.format(on_sheet: on_sheet)})"
  end

  # We'll probably want to abstract this into an interface or common class or something, but for now just define here
  sig { returns(T::Boolean) }
  def array_formula?
    @array_formula
  end
end
