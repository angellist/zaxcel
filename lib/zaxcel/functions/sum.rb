# frozen_string_literal: true
# typed: strict

class Zaxcel::Functions::Sum < Zaxcel::Function
  extend T::Sig

  # Excel drops a formula exceeding 255 args on open; above the limit we collapse consecutive same-column cells into value-identical ranges (SUM(O5:O264)).
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

  # Only same-sheet relative refs merge; literals, cross-sheet/absolute refs, ranges, duplicates, and gaps pass through, so the value is preserved.
  sig { params(args: T::Array[String]).returns(T::Array[String]) }
  def collapse_consecutive_cells(args)
    out = T.let([], T::Array[String])
    run = T.let([], T::Array[String])
    run_col = T.let(nil, T.nilable(String))
    run_row = T.let(nil, T.nilable(Integer))

    args.each do |arg|
      match = arg.match(CELL_REF)
      if match && run_col == match[1] && !run_row.nil? && match[2].to_i == run_row + 1
        run << arg
        run_row = match[2].to_i
      else
        out.concat(flush_run(run))
        if match
          run = [arg]
          run_col = match[1]
          run_row = match[2].to_i
        else
          run = []
          run_col = nil
          run_row = nil
          out << arg
        end
      end
    end
    out.concat(flush_run(run))
    out
  end

  sig { params(run: T::Array[String]).returns(T::Array[String]) }
  def flush_run(run)
    return [] if run.empty?
    return [T.must(run.first)] if run.size == 1

    ["#{run.first}:#{run.last}"]
  end
end
