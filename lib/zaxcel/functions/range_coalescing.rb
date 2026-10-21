# frozen_string_literal: true
# typed: strict

# Compacts formatted aggregate arguments only when Excel's argument limit is exceeded.
# Non-contiguous arguments may still exceed the limit after coalescing.
module Zaxcel::Functions::RangeCoalescing
  MAX_FUNCTION_ARGS = 255
  CELL_REF = T.let(/\A([A-Z]+)(\d+)\z/, Regexp)

  class << self
    extend T::Sig

    # Combines consecutive same-sheet relative references while preserving argument order
    # and duplicate occurrences. Other arguments act as boundaries between runs.
    #
    # @param args [Array<String>] formatted Excel arguments
    # @return [Array<String>] arguments with consecutive cells combined above the limit;
    #   the original array when at or below the limit
    sig { params(args: T::Array[String]).returns(T::Array[String]) }
    def coalesce(args)
      return args if args.size <= MAX_FUNCTION_ARGS

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

    private

    sig { params(run: T::Array[String]).returns(T::Array[String]) }
    def flush_run(run)
      return [] if run.empty?
      return [T.must(run.first)] if run.size == 1

      ["#{run.first}:#{run.last}"]
    end
  end
end
