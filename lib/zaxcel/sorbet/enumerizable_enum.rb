# frozen_string_literal: true
# typed: strict

require 'active_support/concern'

# Include this in a sorbet typed enum (T::Enum) so that it can be used easily with the `enumerize` gem:
# ```ruby
#   class Category < T::Enum
#     enums do
#       One = new(:one)
#       Two = new(:two)
#     end
#   end
#
#   enumerize(
#    :category,
#    in: Category.enumerize_values,
#    value_class: Category,
#  )
# ```
module Sorbet::EnumerizableEnum
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Generic

  # Enumerize requires that `value` on an instance of the `value_class` returns the enum's underlying value.
  sig { returns(Symbol) }
  def value = T.bind(self, T::Enum).serialize

  class_methods do
    extend T::Sig

    # Monkey patch new to call `new` on `T::Enum` if a single value is passed in, otherwise call `deserialize` on the
    # on the enum class. Enumerize calls `new` on the value class with two args; the second of which is the underlying
    # value.
    sig { params(args: T.untyped).returns(T.untyped) }
    def new(*args)
      return super if args.length == 1

      T.bind(self, T.class_of(T::Enum)).deserialize(args[1].to_sym)
    end

    sig { returns(T::Array[Symbol]) }
    def enumerize_values
      T.bind(self, T.class_of(T::Enum)).values.map(&:serialize)
    end
  end
end
