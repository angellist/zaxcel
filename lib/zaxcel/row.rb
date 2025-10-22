# frozen_string_literal: true
# typed: strict

class Zaxcel::Row
  extend T::Sig

  sig { returns(Symbol) }
  attr_reader :name, :style_group

  sig { returns(T.nilable(Integer)) }
  attr_reader :height

  sig { returns(T.nilable(Integer)) }
  attr_reader :position

  sig { params(row_name: Symbol, sheet: Zaxcel::Sheet, style_group: Symbol, height: T.nilable(Integer), hidden: T::Boolean).void }
  def initialize(row_name, sheet:, style_group: :row_style, height: nil, hidden: false)
    @name = row_name
    @sheet = sheet
    @style_group = style_group
    @height = height
    @print_boundary = T.let(false, T::Boolean)
    @hidden = hidden
  end

  sig { params(col_name: T.any(String, Symbol), sheet_name: T.nilable(String)).returns(Zaxcel::References::Cell) }
  def ref(col_name, sheet_name: nil)
    Zaxcel::References::Cell.new(document: @sheet.document, sheet_name: sheet_name || @sheet.name, col_name: col_name.to_sym, row_name: @name)
  end

  sig { params(column_name: T.any(Symbol, String), value: Zaxcel::Cell::ValueType, style: T.nilable(Symbol), to_extract: T::Boolean).returns(Zaxcel::Row) }
  def add!(column_name, value:, style: nil, to_extract: false)
    column = @sheet.column(column_name)
    raise "Cannot add a cell to a non-existent column #{column_name}" if column.nil?

    cell_by_column_name[column_name.to_sym] = column.add_cell!(value: value, row: self, style: style, to_extract: to_extract)

    self
  end

  sig { params(col_name: T.any(Symbol, String)).void }
  def add_empty!(col_name)
    add!(col_name, value: Zaxcel::Cell::EMPTY_VALUE)
  end

  sig { params(cell_value_hash: T::Hash[Symbol, Zaxcel::Cell::ValueType]).returns(Zaxcel::Row) }
  def add_many!(cell_value_hash)
    cell_value_hash.each do |col_name, value|
      add!(col_name.to_sym, value: value)
    end

    self
  end

  sig { params(column_name: T.any(Symbol, String)).returns(T.nilable(Zaxcel::Cell)) }
  def cell(column_name)
    cell_by_column_name[column_name.to_sym]
  end

  sig { params(row_position: Integer).void }
  def position!(row_position)
    @position = T.let(row_position, T.nilable(Integer))
  end

  sig { returns(T::Hash[Symbol, Zaxcel::Cell]) }
  def cell_by_column_name
    @cell_by_column_name ||= T.let({}, T.nilable(T::Hash[Symbol, Zaxcel::Cell]))
  end

  sig { returns(String) }
  def to_excel
    raise 'Must position cells before calling to_excel' if @position.nil?

    @position.to_s
  end

  sig { void }
  def set_print_boundary!
    raise 'Print boundary row already exists' if @sheet.print_boundary_row.present?

    @print_boundary = true
  end

  sig { returns(T::Boolean) }
  def print_boundary?
    @print_boundary
  end

  sig { returns(T::Boolean) }
  def hidden?
    @hidden
  end
end
