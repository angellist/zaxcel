# frozen_string_literal: true
# typed: strict

class Zaxcel::References::Column < Zaxcel::Reference
  extend T::Sig

  sig { override.returns(String) }
  attr_reader :sheet_name

  sig { params(sheet_name: String, col_name: Symbol, document: Zaxcel::Document).void }
  def initialize(sheet_name:, col_name:, document:)
    super()

    @sheet_name = sheet_name
    @col_name = col_name
    @document = document
  end

  sig { override.returns(String) }
  def resolve
    T.must_because(column) { "No column on sheet #{sheet_name} named #{@col_name}" }
      .to_excel
  end

  sig { returns(T.nilable(Zaxcel::Column)) }
  def column
    @column ||= T.let(@document.sheet(@sheet_name)&.column(@col_name), T.nilable(Zaxcel::Column))
  end

  sig { override.returns(String) }
  def excel_sheet_name
    T.must(@document.sheet_by_name[@sheet_name]&.to_excel)
  end

  sig { returns(T::Array[Zaxcel::Cell]) }
  def cells
    return [] if column.nil?

    @cells ||= T.let(
      begin
        cells_in_column = T.must(column).cell_by_row_name.values
        raise 'Must position cells before resolving references.' if cells_in_column.any? { |cell| cell.col_position.nil? }

        cells_in_column.sort_by { |cell| T.must(cell.row_position) }
      end,
      T.nilable(T::Array[Zaxcel::Cell]),
    )
  end
end
