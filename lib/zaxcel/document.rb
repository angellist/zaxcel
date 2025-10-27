# frozen_string_literal: true
# typed: strict

class Zaxcel::Document
  extend T::Sig

  MAX_SHEET_NAME_LENGTH = 31
  DEFAULT_WIDTH_UNITS_BY_DEFAULT_CHARACTER = 0.85 # empirically determined for 11pt body Calibri

  sig { returns(Float) }
  attr_reader :width_units_by_default_character

  sig { params(width_units_by_default_character: Float).void }
  def initialize(width_units_by_default_character: DEFAULT_WIDTH_UNITS_BY_DEFAULT_CHARACTER)
    @document = T.let(Axlsx::Package.new, Axlsx::Package)
    @document.workbook.escape_formulas = false
    @width_units_by_default_character = width_units_by_default_character
  end

  sig { params(sheet: Axlsx::Worksheet, range_to_include: String).void }
  def set_print_area(sheet:, range_to_include:)
    @document.workbook.add_defined_name(range_to_include.to_s, local_sheet_id: sheet.index, name: '_xlnm.Print_Area')
  end

  sig { params(sheet_name: String, sheet_visibility: Zaxcel::Sheet::SheetVisibility).returns(Zaxcel::Sheet) }
  def add_sheet!(sheet_name, sheet_visibility: Zaxcel::Sheet::SheetVisibility::Visible)
    clean_sheet_name = clean_sheet_name(sheet_name)

    worksheet = @document.workbook.add_worksheet({ name: clean_sheet_name })
    worksheet.page_setup.fit_to(width: 1, height: 1)

    # This is necessary to show grouped columns, etc. The default value is false, which is inconsistent with new
    # new documents created in excel. See https://github.com/caxlsx/caxlsx/issues/344 for additional context.
    worksheet.sheet_view.show_outline_symbols = true

    sheet = Zaxcel::Sheet.new(name: sheet_name, document: self, worksheet: worksheet, visibility: sheet_visibility)
    sheet_by_name[sheet_name] = sheet

    sheet
  end

  sig { params(name: Symbol).returns(T.nilable(Integer)) }
  def style(name)
    styles_by_style_name[name]
  end

  sig { params(name: Symbol, kwargs: T.untyped).returns(Integer) }
  def add_style!(name, **kwargs)
    styles_by_style_name[name] ||= @document.workbook.styles.add_style(**kwargs)
  end

  sig { returns(T::Hash[Symbol, Integer]) }
  def styles_by_style_name
    @styles ||= T.let({}, T.nilable(T::Hash[Symbol, Integer]))
  end

  sig { params(name: String).returns(T.nilable(Zaxcel::Sheet)) }
  def sheet(name)
    sheet_by_name[name]
  end

  sig { returns(T::Hash[String, Zaxcel::Sheet]) }
  def sheet_by_name
    @sheet_by_name ||= T.let({}, T.nilable(T::Hash[String, Zaxcel::Sheet]))
  end

  sig { returns(T.nilable(String)) }
  def file_contents
    stream = T.cast(@document.to_stream, T.any(StringIO, T::Boolean))
    return if !stream.is_a?(StringIO)

    stream.read
  end

  # this exposes the underlying axlsx document directly. it's an escape hatch for modifying the document in ways not
  # directly supported by zaxcel. it is unsafe in that it can break zaxcel's assumptions about the document leading to
  # unintended consequences. use with caution.
  sig { returns(Axlsx::Package) }
  def unsafe_axlsx_document
    @document
  end

  sig { params(sheet_name: String, pending_sheet_names: T::Array[String]).returns(String) }
  def clean_sheet_name(sheet_name, pending_sheet_names: [])
    # sheet names in excel must
    # 1. be max 31 charaters
    # 2. not special characters
    # 3. be unique
    cleaned_sheet_name = sheet_name.gsub(/[^0-9a-z_ ]/i, '').parameterize(
      separator: ' ',
      preserve_case: true,
    ).first(MAX_SHEET_NAME_LENGTH)

    unique_index = 0

    unique_name = cleaned_sheet_name
    while @document.workbook.sheet_by_name(unique_name).present? || pending_sheet_names.include?(unique_name)
      unique_index += 1
      unique_name = "#{cleaned_sheet_name.first(cleaned_sheet_name.length - unique_index.to_s.length)}#{unique_index}"
    end

    unique_name
  end

  class << self
    extend T::Sig

    sig { params(start_reference: Zaxcel::References::Cell, end_reference: Zaxcel::References::Cell).returns(T::Array[Zaxcel::Cell]) }
    def cells_in_range(start_reference:, end_reference:)
      cell_start = T.must(start_reference.cell)
      cell_end = T.must(end_reference.cell)

      if cell_start.column == cell_end.column
        column = cell_start.column

        cells_in_column = column.cell_by_row_name.values
        cells_in_column.select do |cell|
          row_position = T.must(cell.row_position)

          row_position >= T.must(cell_start.row_position) && row_position <= T.must(cell_end.row_position)
        end
      elsif cell_start.row == cell_end.row
        row = cell_start.row

        cells_in_row = row.cell_by_column_name.values
        cells_in_row.select do |cell|
          col_position = T.must(cell.col_position)

          col_position >= T.must(cell_start.col_position) && col_position <= T.must(cell_end.col_position)
        end
      else
        raise 'Cells must be in the same row or column in order to sum'
      end
    end
  end
end
