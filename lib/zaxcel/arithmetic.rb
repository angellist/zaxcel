# frozen_string_literal: true
# typed: strict

module Zaxcel::Arithmetic
  include Kernel
  include ActiveSupport::Tryable
  extend T::Sig

  class CoercedValue < T::Struct
    extend T::Sig
    include Zaxcel::Arithmetic

    const(:value, T.any(Numeric, Money))

    sig { params(on_sheet: String).returns(T.any(Numeric, Money)) }
    def format(on_sheet:)
      value
    end

    sig { returns(T::Boolean) }
    def additive_identity?
      object_id == Zero.object_id
    end
  end

  Zero = CoercedValue.new(value: 0)
  private_constant :Zero

  #
  # https://docs.ruby-lang.org/en/master/Numeric.html
  #
  # > Classes which inherit from Numeric must implement coerce, which returns a two-member Array containing an object
  # > that has been coerced into an instance of the new class and self (see coerce).
  # >
  # > Inheriting classes should also implement arithmetic operator methods (+, -, * and /) and the <=> operator
  # > (see Comparable). These methods may rely on coerce to ensure interoperability with instances of other numeric
  # > classes.
  #
  # Inheriting from Numeric allows us to add Zaxcel objects like cell references and formulas to Ruby numerics.
  # For example:
  #   `1 + cell_ref` will call coerce on `1` and return a `Zaxcel::CellFormula` object representing the sum.

  sig { params(other: T.any(Numeric, Money)).returns([CoercedValue, Zaxcel::Arithmetic]) }
  def coerce(other)
    [CoercedValue.new(value: other), self]
  end

  # These need to be implemented as part of the Numeric interface.

  sig { returns(Zaxcel::CellFormula) }
  def -@
    Zaxcel::Functions::Negate.new(self)
  end

  sig { params(other: T.any(Numeric, Money, Zaxcel::Arithmetic)).returns(Zaxcel::Arithmetic) }
  def +(other)
    Zaxcel::BinaryExpressions::Addition.new(self, other)
  end

  sig { params(other: T.any(Numeric, Money, Zaxcel::Arithmetic)).returns(Zaxcel::CellFormula) }
  def -(other)
    Zaxcel::BinaryExpressions::Subtraction.new(self, other)
  end

  sig { params(other: T.any(Numeric, Money, Zaxcel::Arithmetic)).returns(Zaxcel::CellFormula) }
  def *(other)
    Zaxcel::BinaryExpressions::Multiplication.new(self, other)
  end

  sig { params(other: T.any(Numeric, Money, Zaxcel::Arithmetic)).returns(Zaxcel::CellFormula) }
  def /(other)
    Zaxcel::BinaryExpressions::Division.new(self, other)
  end

  sig { returns(TrueClass) }
  def present?
    true
  end

  class << self
    extend T::Sig

    sig { returns(Zaxcel::Arithmetic) }
    def zero
      Zero
    end
  end
end
