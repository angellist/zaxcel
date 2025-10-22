# frozen_string_literal: true
# typed: strict

class Zaxcel::Sheet
  extend T::Sig

  HEADER_ROW_KEY = :header_row

  sig { returns(String) }
  attr_reader :name

  sig { returns(Zaxcel::Document) }
  attr_reader :document

  sig { returns(T::Hash[Zaxcel::Cell::CellExtractionKey, Zaxcel::Cell]) }
  attr_reader :cells_by_extraction_key

  class SheetVisibility < T::Enum
    include Sorbet::EnumerizableEnum

    enums do
      Visible = new(:visible)
      Hidden = new(:hidden) # Can be unhidden from Excel UI
      # VeryHidden is here if we really need it at some point, but pay attention to:
      # - who is potentially going to be accessing this sheet and how will they react to a sheet referenced which cannot be accessed via UI
      # VeryHidden = new(:very_hidden) # Requires code to unhide (e.g. VBA)
    end
  end

  sig { params(name: String, document: Zaxcel::Document, worksheet: Axlsx::Worksheet, visibility: Zaxcel::Sheet::SheetVisibility).void }
  def initialize(name:, document:, worksheet:, visibility: Zaxcel::Sheet::SheetVisibility::Visible)
    @name = name
    @document = document
    @worksheet = worksheet
    @visibility = visibility
    @cells_by_extraction_key = T.let({}, T::Hash[Zaxcel::Cell::CellExtractionKey, Zaxcel::Cell])
  end

  # returns the underlying axlsx worksheet. this an escape hatch to allow operations not supported by zaxcel.
  # this is unsafe because it allows you to mutate the worksheet in ways that zaxcel doesn't know about.
  sig { returns(Axlsx::Worksheet) }
  def unsafe_axlsx_worksheet
    @worksheet
  end

  sig { returns(String) }
  def to_excel
    @worksheet.name
  end

  sig { void }
  def position_rows!
    rows.each_with_index do |row, i|
      row_position = i + 1 # 1 indexed not 0 indexed
      row.position!(row_position)

      # First persist the location of each cell
      columns.each_with_index do |column, j|
        column.position!(j)

        # add an empty cell anywhere that's missing. this makes cell references work more intuitively.
        # for instance, if I want to reference the top left cell in some area so I can define a merge range,
        # it should resolve whether I define that cell or not.
        cell = column.cell(row.name)
        if cell.nil?
          column.add_cell!(row: row)
        elsif cell.to_extract?
          @cells_by_extraction_key[cell.extraction_key] = cell
        end
      end
    end
  end

  sig { returns(T::Array[T.nilable(T.any(Float, Integer))]) }
  def column_widths
    columns.map do |col|
      next T.cast(col.width, T.nilable(T.any(Float, Integer))) if !Zaxcel::Column::ComputedColumnWidth.values.include?(col.width)

      character_length = case col.width
                         when Zaxcel::Column::ComputedColumnWidth::MaxContent
                           rows.map do |row|
                             cell = col.cell(row.name)
                             next 0 if cell.nil? || cell.value.is_a?(Zaxcel::References::Column)

                             cell.estimated_formatted_character_length
                           end.compact.max
                         when Zaxcel::Column::ComputedColumnWidth::Header
                           col.cell(HEADER_ROW_KEY)&.estimated_formatted_character_length || 0
                         when Zaxcel::Column::ComputedColumnWidth::HeaderTwoLines
                           # if we ever have to do fit to more than two lines (don't think we ever would),
                           # just refac this to support N lines and pass N in somehow
                           uneven_line_break_buffer = 3
                           (((col.cell(HEADER_ROW_KEY)&.estimated_formatted_character_length || 0) / 2) + uneven_line_break_buffer)
                         end

      next if character_length.nil?

      [column_width_from_content_length(character_length), col.min_width].max
    end
  end

  # An alternative to allowing CAXLSX to auto-calculate the width of a column,
  # since it sometimes gives way too much extra space.
  sig { params(content_length: Integer).returns(Integer) }
  def column_width_from_content_length(content_length)
    (document.width_units_by_default_character * content_length).ceil
  end

  sig { void }
  def add_rows_to_worksheet!
    rows.each_with_index do |row, _rowi|
      cells_in_row = columns.map { |col| col.cell(row.name) }
      formatted_cells = cells_in_row.map { |cell| format_cell_contents(cell) }
      @worksheet.add_row(
        formatted_cells,
        style: cells_in_row.map { |c| @document.style(c&.style || :default_cell) },
        height: row.height
      )
      @worksheet.column_widths(*T.unsafe(column_widths))
    end
  end

  sig { returns(T.nilable(Zaxcel::Column)) }
  def print_boundary_column
    columns.find(&:print_boundary?)
  end

  sig { returns(T.nilable(Zaxcel::Row)) }
  def print_boundary_row
    rows.find(&:print_boundary?)
  end

  sig { void }
  def set_print_area!
    first_column_to_print = columns.first!
    last_column_to_print = print_boundary_column || T.must(columns.last)

    first_row_to_print = rows.first!
    last_row_to_print = print_boundary_row || T.must(rows.last)

    print_area_range = "'#{to_excel}'!#{first_column_to_print.to_excel}#{first_row_to_print.to_excel}:#{last_column_to_print.to_excel}#{last_row_to_print.to_excel}"

    @document.set_print_area(sheet: @worksheet, range_to_include: print_area_range)
  end

  sig { void }
  def apply_conditional_formatting!
    conditional_formatting.each do |formatting|
      range = formatting[:range]
      if range.is_a?(Zaxcel::References::Column)
        first_cell = range.cells.first!
        last_cell = T.must(range.cells.last)
      else
        range = T.cast(range, T::Array[Zaxcel::References::Cell])
        first_cell = range.first!.cell
        last_cell = T.must(range.last).cell
      end

      @worksheet.add_conditional_formatting(
        "#{T.must(first_cell).to_excel}:#{T.must(last_cell).to_excel}",
        type: formatting[:rule],
        dxfId: @document.style(formatting[:style]),
        priority: 1 # i don't know what this means :)
      )
    end
  end

  sig { void }
  def apply_cell_merges!
    ranges_to_merge.each do |range|
      cells = range.map(&:cell).compact

      first_column_cell = cells.min_by { |cell| T.must(cell.col_position) }
      first_row_cell = cells.min_by { |cell| T.must(cell.row_position) }
      last_column_cell = cells.max_by { |cell| T.must(cell.col_position) }
      last_row_cell = cells.max_by { |cell| T.must(cell.row_position) }
      # if any of the references don't resolve, then just skip this range
      next if first_column_cell.nil? || first_row_cell.nil? || last_column_cell.nil? || last_row_cell.nil?

      top_left_cell_position = "#{first_column_cell.column.to_excel}#{first_row_cell.row.to_excel}"
      bottom_right_cell_position = "#{last_column_cell.column.to_excel}#{last_row_cell.row.to_excel}"

      @worksheet.merge_cells("#{top_left_cell_position}:#{bottom_right_cell_position}")
    end
  end

  sig { void }
  def hide_columns!
    columns.select(&:hidden?).each do |column|
      @worksheet.column_info[column.position].hidden = true
    end
  end

  sig { void }
  def hide_rows!
    rows.each_with_index do |row, i|
      next unless row.hidden?

      @worksheet.rows[i].hidden = true
    end
  end

  sig { void }
  def apply_sheet_visibility!
    @worksheet.state = @visibility.serialize
  end

  # it woudl be cool to specify a cell as an image instead...
  sig do
    params(image_path: String, width: Integer, height: Integer, row_position: Integer, column_position: Integer).void
  end
  def add_image_to_worksheet!(image_path, width:, height:, row_position:, column_position:)
    @worksheet.add_image(
      image_src: image_path,
      noMove: true
    ) do |image|
      image.width = width
      image.height = height
      image.start_at(column_position, row_position)
    end
  end

  sig { void }
  def generate_sheet!
    add_rows_to_worksheet!
    set_print_area!

    apply_cell_merges!
    apply_conditional_formatting!
    hide_columns!
    hide_rows!
    apply_sheet_visibility!
  end

  sig { params(row_name: T.any(Symbol, String)).returns(T.nilable(Zaxcel::Row)) }
  def row(row_name)
    rows_by_name[row_name.to_sym]
  end

  sig { params(column_name: T.any(Symbol, String)).returns(T.nilable(Zaxcel::Column)) }
  def column(column_name)
    columns_by_name[column_name.to_sym]
  end

  sig do
    params(name: T.any(Symbol, String, Numeric), style_group: Symbol, height: T.nilable(Integer),
           hidden: T::Boolean).returns(Zaxcel::Row)
  end
  def add_row!(name, style_group: :row_style, height: nil, hidden: false)
    name = name.to_s if name.is_a?(Numeric)
    rows_by_name[name.to_sym] ||= Zaxcel::Row.new(name.to_sym, sheet: self, style_group: style_group, height: height,
                                                               hidden: hidden)
  end

  sig { params(style_group: Symbol).returns(Zaxcel::Row) }
  def add_empty_row!(style_group: :row_style)
    add_row!(SecureRandom.uuid.delete('-'), style_group: style_group)
  end

  sig do
    params(
      name: T.any(Symbol, String),
      header: String,
      header_style: Symbol,
      row_style: Symbol,
      first_row_style: Symbol,
      total_style: T.nilable(Symbol),
      width: T.nilable(T.any(Integer, Float, Zaxcel::Column::ComputedColumnWidth)),
      alt_row_style: T.nilable(Symbol),
      min_width: T.nilable(T.any(Integer, Float))
    ).returns(Zaxcel::Column)
  end
  def add_column!(
    name,
    header: '',
    header_style: :default_cell,
    row_style: :default_cell,
    first_row_style: :default_cell,
    total_style: nil,
    width: Zaxcel::Column::DEFAULT_COLUMN_WIDTH,
    alt_row_style: nil,
    min_width: 0
  )
    columns_by_name[name.to_sym] ||= Zaxcel::Column.new(
      sheet: self,
      name: name.to_sym,
      header: header,
      header_style: header_style,
      row_style: row_style,
      first_row_style: first_row_style,
      total_style: total_style,
      width: width,
      alt_row_style: alt_row_style,
      min_width: min_width
    )
  end

  sig { params(width: T.nilable(T.any(Integer, Float))).returns(Zaxcel::Column) }
  def add_empty_column!(width: Zaxcel::Column::DEFAULT_COLUMN_WIDTH)
    add_column!(SecureRandom.uuid.delete('-'), width: width)
  end

  sig do
    params(
      range: T.any(Zaxcel::References::Column, T::Array[Zaxcel::References::Cell]),
      rule: Symbol,
      style: Symbol
    ).void
  end
  def add_conditional_formatting!(range:, rule:, style:)
    conditional_formatting << { range: range, rule: rule, style: style }
  end

  sig { params(range: T::Array[Zaxcel::References::Cell]).void }
  def merge_cells!(range)
    ranges_to_merge << range
  end

  sig { returns(T::Array[T::Array[Zaxcel::References::Cell]]) }
  def ranges_to_merge
    @ranges_to_merge ||= T.let([], T.nilable(T::Array[T::Array[Zaxcel::References::Cell]]))
  end

  sig { returns(T::Array[Zaxcel::Column]) }
  def columns
    columns_by_name.values
  end

  sig { returns(T::Array[Zaxcel::Row]) }
  def rows
    rows_by_name.values
  end

  sig { params(height: T.nilable(Integer)).returns(Zaxcel::Row) }
  def add_column_header_row!(height: nil)
    add_row!(HEADER_ROW_KEY, style_group: :header_style, height: height)
      .add_many!(columns.map { |c| [c.name, c.header] }.to_h)
  end

  sig { returns(T::Hash[Symbol, Zaxcel::Row]) }
  def rows_by_name
    @rows_by_name ||= T.let({}, T.nilable(T::Hash[Symbol, Zaxcel::Row]))
  end

  sig { returns(T::Hash[Symbol, Zaxcel::Column]) }
  def columns_by_name
    @columns_by_name ||= T.let({}, T.nilable(T::Hash[Symbol, Zaxcel::Column]))
  end

  sig { returns(T::Array[{ range: T.any(Zaxcel::References::Column, T::Array[Zaxcel::References::Cell]), rule: Symbol, style: Symbol }]) }
  def conditional_formatting
    @conditional_formatting ||= T.let([],
                                      T.nilable(T::Array[{ range: T.any(Zaxcel::References::Column, T::Array[Zaxcel::References::Cell]), rule: Symbol,
                                                           style: Symbol }]))
  end

  sig { void }
  def hide_gridlines!
    @worksheet.sheet_view.show_grid_lines = false
  end

  sig { void }
  def print_landscape!
    @worksheet.print_options.horizontal_centered = true
    @worksheet.page_setup.orientation = :landscape
  end

  sig do
    params(col_name: T.any(Symbol, String), row_name: T.any(Symbol, String, Numeric),
           sheet_name: T.nilable(String)).returns(Zaxcel::References::Cell)
  end
  def cell_ref(col_name, row_name, sheet_name: nil)
    row_name = row_name.to_s if row_name.is_a?(Numeric)
    Zaxcel::References::Cell.new(document: @document, sheet_name: sheet_name || @name, row_name: row_name.to_sym,
                                 col_name: col_name.to_sym)
  end

  sig { params(col_name: T.any(Symbol, String), sheet_name: T.nilable(String)).returns(Zaxcel::References::Column) }
  def column_ref(col_name, sheet_name: nil)
    Zaxcel::References::Column.new(document: @document, sheet_name: sheet_name || @name, col_name: col_name.to_sym)
  end

  private

  sig { params(cell: T.nilable(Zaxcel::Cell)).returns(T.nilable(T.any(Numeric, Money, String))) }
  def format_cell_contents(cell)
    value = cell&.value
    base_format = Zaxcel::Cell.format(value, on_sheet: @name, quote_strings: false)
    # always pass along numerics + money + nil as is for caxlsx to print directly
    return base_format unless base_format.is_a?(String)

    # prefix the evaluation operator if the result is a cell formula
    if value.is_a?(Time) || value.is_a?(Zaxcel::CellFormula) || value.is_a?(Zaxcel::Reference) || value.is_a?(TrueClass) || value.is_a?(FalseClass)
      base_format = "=#{base_format}"

      # array formulas need to be wrapped in curly braces for CAXLSX. See
      # https://github.com/caxlsx/caxlsx/blob/master/lib/axlsx/workbook/worksheet/cell.rb#L422 and
      # https://github.com/caxlsx/caxlsx/blob/master/lib/axlsx/workbook/worksheet/cell_serializer.rb#L101
      base_format = "{#{base_format}}" if value.respond_to?(:array_formula?) && T.unsafe(value).array_formula?
    end

    base_format
  end
end
