# frozen_string_literal: true
# typed: strict

class Zaxcel::IfBuilder
  extend T::Sig

  sig { params(condition: Zaxcel::Cell::ValueType).void }
  def initialize(condition)
    @condition = T.let(condition, Zaxcel::Cell::ValueType)
  end

  sig { params(result: Zaxcel::Cell::ValueType).returns(Zaxcel::IfBuilder) }
  def then(result)
    @then = T.let(result, Zaxcel::Cell::ValueType)
    self
  end

  sig { params(result: Zaxcel::Cell::ValueType).returns(Zaxcel::Functions::If) }
  def else(result)
    Zaxcel::Functions::If.new(@condition, if_true: @then, if_false: result)
  end
end
