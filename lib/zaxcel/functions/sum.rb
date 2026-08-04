# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Sum < Zaxcel::Function
  extend T::Sig

  # Excel caps functions at 255 args; above that we collapse consecutive same-column cells into ranges.
  MAX_FUNCTION_ARGS = 255

  CELL_REF = T.let(/\A([A-Z]+)(\d+)\z/, Regexp)

  sig { params(values: T::Array[T.any(Zaxcel::Cell::ValueType, Zaxcel::References::Range)]).void }
  def initialize(values)
    @values = values
  end

  sig { override.params(on_sheet: String).returns(String) }
  def format(on_sheet:)
    return '0' if @values.blank?

    args = @values.map { |value| Zaxcel::Cell.format(value, on_sheet: on_sheet).to_s }
    args = collapse_consecutive_cells(args) if args.size > MAX_FUNCTION_ARGS
    "SUM(#{args.join(',')})"
  end

  private

  # Group maximal runs of consecutive same-column cells (A1,A2,A3 -> A1:A3). Only plain same-sheet
  # relative refs join a run; literals, cross-sheet/absolute refs, ranges, duplicates and gaps break it.
  sig { params(args: T::Array[String]).returns(T::Array[String]) }
  def collapse_consecutive_cells(args)
    args.slice_when { |left, right| !consecutive_cells?(left, right) }.map do |run|
      run.size > 1 ? "#{run.first}:#{run.last}" : run.first
    end
  end

  sig { params(left: String, right: String).returns(T::Boolean) }
  def consecutive_cells?(left, right)
    left_match = left.match(CELL_REF)
    right_match = right.match(CELL_REF)
    return false if left_match.nil? || right_match.nil?

    left_match[1] == right_match[1] && right_match[2].to_i == left_match[2].to_i + 1
  end
end
