# frozen_string_literal: true
# typed: true

module Enumerable
  sig { returns(Elem) }
  def first!; end

  sig { returns(Elem) }
  def last!; end

  sig { params(blk: T.proc.params(arg0: Elem).returns(BasicObject)).returns(Elem) }
  sig { returns(T::Enumerator[Elem]) }
  def find!(&blk); end

  sig { params(blk: T.proc.params(arg0: Elem).returns(BasicObject)).returns(Elem) }
  sig { returns(T::Enumerator[Elem]) }
  def detect!(&blk); end

  sig { returns(Elem) }
  def min!; end

  sig { returns(Elem) }
  def max!; end

  sig { returns(T::Boolean) }
  def blank?; end
end


