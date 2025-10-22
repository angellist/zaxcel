# frozen_string_literal: true
# typed: strict

class Zaxcel::Column
  extend T::Sig

  DEFAULT_COLUMN_WIDTH = 20
  class ComputedColumnWidth < T::Enum
    enums do
      MaxContent = new
      Header = new
      HeaderTwoLines = new
    end
  end

  sig { returns(Symbol) }
  attr_reader :name

  sig { returns(String) }
  attr_reader :header

  sig { returns(Symbol) }
  attr_reader :header_style

  sig { returns(Symbol) }
  attr_reader :row_style

  sig { returns(Symbol) }
  attr_reader :alt_row_style

  sig { returns(Symbol) }
  attr_reader :first_row_style

  sig { returns(T.nilable(Symbol)) }
  attr_reader :total_style

  # You can specify `nil` and CAXLSX will auto-calculate an appropriate width based on the column's contents.
  sig { returns(T.nilable(T.any(Integer, Float, ComputedColumnWidth))) }
  attr_reader :width

  sig { returns(T.nilable(T.any(Integer, Float))) }
  attr_reader :min_width

  sig { returns(Zaxcel::Sheet) }
  attr_reader :sheet

  sig { params(sheet: Zaxcel::Sheet, name: T.any(Symbol, String), header: String, header_style: Symbol, row_style: Symbol, first_row_style: Symbol, total_style: T.nilable(Symbol), alt_row_style: T.nilable(Symbol), width: T.nilable(T.any(Integer, Float, ComputedColumnWidth)), min_width: T.nilable(T.any(Integer, Float))).void }
  def initialize(sheet:, name:, header:, header_style:, row_style:, first_row_style:, total_style:, alt_row_style: nil, width: DEFAULT_COLUMN_WIDTH, min_width: 0)
    @sheet = sheet
    @name = T.let(name.to_sym, Symbol)
    @header = header
    @header_style = header_style
    @row_style = row_style
    @alt_row_style = T.let(alt_row_style || row_style, Symbol)
    @first_row_style = first_row_style
    @total_style = total_style
    @width = width
    @min_width = min_width
    @print_boundary = T.let(false, T::Boolean)
    @hidden = T.let(false, T::Boolean)
  end

  sig { params(row_name: T.any(String, Symbol), sheet_name: T.nilable(String)).returns(Zaxcel::References::Cell) }
  def ref(row_name, sheet_name: nil)
    Zaxcel::References::Cell.new(document: @sheet.document, sheet_name: sheet_name || @sheet.name, col_name: @name, row_name: row_name.to_sym)
  end

  sig { params(row: Zaxcel::Row, value: T.nilable(Zaxcel::Cell::ValueType), style: T.nilable(Symbol), to_extract: T::Boolean).returns(Zaxcel::Cell) }
  def add_cell!(row:, value: nil, style: nil, to_extract: false)
    cell_by_row_name[row.name] = Zaxcel::Cell.new(
      column: self,
      row: row,
      style: style,
      value: value,
      to_extract: to_extract,
    )
  end

  sig { params(row_name: T.any(Symbol, String)).returns(T.nilable(Zaxcel::Cell)) }
  def cell(row_name)
    cell_by_row_name[row_name.to_sym]
  end

  sig { params(column_position: Integer).void }
  def position!(column_position)
    @position = T.let(column_position, T.nilable(Integer))
  end

  sig { returns(T.nilable(Integer)) }
  def position
    @position
  end

  # Excel uses letters for column names. When it reaches 'Z', it starts over with 'AA', 'AB', etc.
  # until it hits 'AZ' and then moves on to 'BZ'. Eventually, it will reach 'ZZ' and start 'AAA'.
  # This method converts the column position to the appropriate sequence of letters.
  sig { returns(String) }
  def to_excel
    raise 'Must position cells before calling to_excel' if @position.nil?

    self.class.base_26_string(@position)
  end

  sig { returns(T::Hash[Symbol, Zaxcel::Cell]) }
  def cell_by_row_name
    @cell_by_row_name ||= T.let({}, T.nilable(T::Hash[Symbol, Zaxcel::Cell]))
  end

  sig { void }
  def hide!
    @hidden = true
  end

  sig { returns(T::Boolean) }
  def hidden?
    @hidden
  end

  sig { void }
  def set_print_boundary!
    raise 'Print boundary column already exists' if @sheet.print_boundary_column.present?

    @print_boundary = true
  end

  sig { returns(T::Boolean) }
  def print_boundary?
    @print_boundary
  end

  class << self
    extend T::Sig

    sig { params(number: Integer).returns(String) }
    def base_26_string(number)
      first_character = (number % 26 + 'A'.ord).chr
      return first_character if number < 26

      "#{base_26_string((number / 26).to_i - 1)}#{(number % 26 + 'A'.ord).chr}"
    end
  end
end
