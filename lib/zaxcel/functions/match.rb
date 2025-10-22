# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Match < Zaxcel::Function
  sig do
    params(
      value: Zaxcel::Cell::ValueType,
      range: Zaxcel::References::Range,
      match_type: T.nilable(Zaxcel::Functions::Match::MatchType),
    ).void
  end
  def initialize(value:, range:, match_type: nil)
    @value = value
    @range = range
    @match_type = match_type
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    args = [
      Zaxcel::Cell.format(@value, on_sheet: on_sheet),
      @range.format(on_sheet: on_sheet),
    ]
    args << @match_type.serialize if @match_type.present?
    "MATCH(#{args.join(',')})"
  end
end
