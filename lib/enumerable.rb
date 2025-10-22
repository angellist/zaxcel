# frozen_string_literal: true
# typed: false

# sigs and typing for these methods are defined in a separate rbi file
# sorbet/rbi/core/enumerable.rbi
module Enumerable
  include Kernel

  def first!
    assert_not_nil!(first)
  end

  def last!
    assert_not_nil!(last)
  end

  def find!(&blk)
    assert_not_nil!(find(&blk))
  end

  def detect!(&blk)
    find!(&blk)
  end

  def min!
    assert_not_nil!(min)
  end

  def max!
    assert_not_nil!(max)
  end

  def max_by!(&blk)
    assert_not_nil!(max_by(&blk))
  end

  private

  def assert_not_nil!(item)
    case item
    when NilClass
      raise "No items in #{self.class}"
    end

    item
  end
end
