# frozen_string_literal: true
# typed: strict

class Zaxcel::Cell
  extend T::Sig

  ConstantValueType = T.type_alias { T.any(NilClass, Numeric, Money, String, Date, Time, TrueClass, FalseClass) }
  ValueType = T.type_alias { T.any(ConstantValueType, Zaxcel::Arithmetic) }
  CellExtractionKey = T.type_alias { [String, Symbol, Symbol] }

  EMPTY_VALUE = ''

  sig { returns(Symbol) }
  attr_reader :style

  sig { returns(T.nilable(ValueType)) }
  attr_reader :value

  sig { returns(Zaxcel::Column) }
  attr_reader :column

  sig { returns(Zaxcel::Row) }
  attr_reader :row

  sig { returns(T::Boolean) }
  attr_reader :to_extract

  sig { params(column: Zaxcel::Column, row: Zaxcel::Row, style: T.nilable(Symbol), value: ValueType, to_extract: T::Boolean).void }
  def initialize(column:, row:, style:, value:, to_extract: false)
    @column = column
    @row = row
    @value = value
    @to_extract = to_extract
    # style can be nil, the name of a style, or the name of a style group
    # if it's nil, fall back to the style_group on the row
    style ||= row.style_group
    # first check if it's a style group, if not, then it's a style
    style = column.try(style) || style

    @style = T.let(style, Symbol)
  end

  sig { returns(String) }
  def to_excel
    if col_position.nil? && row_position.nil?
      return '0' if @value.nil? || @value.try(:zero?)

      raise 'Cannot call to_excel until col and row indices are set. Call position! first'
    end

    "#{@column.to_excel}#{@row.to_excel}"
  end

  sig { returns(T.nilable(Integer)) }
  def row_position
    @row.position
  end

  sig { returns(T.nilable(Integer)) }
  def col_position
    @column.position
  end

  sig { returns(T.nilable(Integer)) }
  def estimated_formatted_character_length
    self.class.estimated_character_length_from_cell_value(@value)
  end

  sig { returns(T::Boolean) }
  def to_extract?
    @to_extract
  end

  sig { returns(CellExtractionKey) }
  def extraction_key
    [column.sheet.name, row.name, column.name]
  end

  class << self
    extend T::Sig

    sig { params(value: T.nilable(ValueType)).returns(T.nilable(Integer)) }
    def estimated_character_length_from_cell_value(value)
      case value
      when String
        value.length
      when Integer, Float, Money, BigDecimal
        # Add 2 for potential negative sign and decimal point
        # Add 1 character per 3 digits for commas
        num_str = value.to_s.gsub(/[.-]/, '')
        num_str.length + 2 + (num_str.length / 3.0).ceil
      when Time
        value.strftime('%m/%d/%Y %H:%M:%S').length
      when Date
        format_date(value).length
      when TrueClass, FalseClass
        value.to_s.length
      when Zaxcel::CellFormula, Zaxcel::References::Cell
        # For formulas and references, we don't know the length until we evaluate them
        nil
      end
    end

    sig do
      params(
        value: T.nilable(T.any(ValueType, Zaxcel::References::Range)),
        on_sheet: String,
        quote_strings: T::Boolean
      ).returns(T.nilable(T.any(Numeric, Money, String)))
    end
    def format(value, on_sheet:, quote_strings: true)
      case value
      when String
        # don't set empty cells to empty string - this allows other cells to overflow into them
        return if value.empty?

        # Strings inside of formulas need to be escaped with quotes, otherwise they cause errors. Strings printed
        # directly into the document (not as part of a formula) should not be escaped.
        quote_strings ? "\"#{value}\"" : value
      when Numeric, Money
        value
      # this must come before date because Time < Date
      when Time
        "DATE(#{value.year}, #{value.month}, #{value.day})+TIME(#{value.hour}, #{value.min}, #{value.sec})"
      when Date
        format_date(value)
      when TrueClass
        'TRUE'
      when FalseClass
        'FALSE'
      when Zaxcel::CellFormula, Zaxcel::References::Cell, Zaxcel::References::Range, Zaxcel::Arithmetic::CoercedValue
        value.format(on_sheet: on_sheet)
      end
    end

    sig { params(value: Date).returns(String) }
    def format_date(value)
      value.strftime('%m/%d/%Y')
    end
  end
end
