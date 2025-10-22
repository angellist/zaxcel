# frozen_string_literal: true
# typed: strict

# https://support.microsoft.com/en-us/office/xirr-function-de1242ec-6477-445b-b11b-a303ad9adc9d
class Zaxcel::Functions::Xirr < Zaxcel::Function
  extend T::Sig

  sig do
    params(
      values: Zaxcel::References::Range,
      dates: Zaxcel::References::Range,
      guess: T.nilable(Zaxcel::CellFormula),
    ).void
  end
  def initialize(values, dates, guess: nil)
    @values = values
    @dates = dates
    @guess = guess
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    guess_string = ", #{Zaxcel::Cell.format(@guess, on_sheet: on_sheet)}" if @guess.present?

    "XIRR(#{@values.format(on_sheet: on_sheet)},#{@dates.format(on_sheet: on_sheet)}#{guess_string})"
  end
end
