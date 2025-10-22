# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Choose < Zaxcel::Function
  extend T::Sig

  sig { params(choice_index: Zaxcel::Cell::ValueType, choices: T::Array[Zaxcel::Cell::ValueType]).void }
  def initialize(choice_index, choices:)
    @choice_index = choice_index
    @choices = choices
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    args = [Zaxcel::Cell.format(@choice_index, on_sheet: on_sheet)]
    args += @choices.map { |choice| Zaxcel::Cell.format(choice, on_sheet: on_sheet) }

    "CHOOSE(#{args.join(',')})"
  end
end
