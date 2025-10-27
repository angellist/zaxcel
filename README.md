# Zaxcel

Zaxcel is a Ruby library built on top of [caxlsx](https://github.com/caxlsx/caxlsx) that adds an abstraction layer to building Excel documents. It provides simple methods for building formulas and references to other cells, even across many worksheets, using a clean Ruby DSL without having to think about the underlying Excel implementation.

## Philosophy

- **Goal**: Enable building Excel sheets in a Ruby-idiomatic DSL without having to think about the underlying Excel. We want to interact with purely Ruby objects in a purely Ruby way while building Excel sheets.
- **Anti-goal**: Reimplementing Excel in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zaxcel'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install zaxcel
```

### Requirements

- Ruby >= 3.0 (tested up to 3.4)
- Runtime dependencies are managed automatically via Rubygems, but you should have Bundler set up in your project. Zaxcel depends on:
  - `caxlsx` (~> 4.0)
  - `activesupport` (>= 6.0)
  - `money` (~> 6.0)
  - `sorbet-runtime` (~> 0.5)

For running examples directly from the repo, prefer using Bundler:

```bash
bundle install
bundle exec ruby examples/basic_spreadsheet.rb
```

## Usage

### Basic Example

```ruby
require 'zaxcel'

# Create a new document
document = Zaxcel::Document.new
sheet = document.add_sheet!('my_sheet')

# Add columns
sheet.add_column!(:column_1)
sheet.add_column!(:column_2)

# Add rows with data
row_1 = sheet.add_row!(:row_1)
  .add!(:column_1, value: 'Row 1')
  .add!(:column_2, value: 99)

row_2 = sheet.add_row!(:row_2)
  .add!(:column_1, value: 'Row 2')
  .add!(:column_2, value: 1)

# Add a total row with a formula that references other cells
sheet.add_row!(:total)
  .add!(:column_1, value: 'Total')
  .add!(:column_2, row_1.ref(:column_2) + row_2.ref(:column_2))

# Finalize the sheet (position and generate after all content is added)
sheet.position_rows!
sheet.generate_sheet!

# Write to file (binary-safe)
data = document.file_contents
raise 'Document had no contents' if data.nil?
File.write('output.xlsx', data, mode: 'wb')
```

### Working with Formulas

Zaxcel makes it easy to build Excel formulas using Ruby operators:

```ruby
# Arithmetic operations
cell_sum = row_1.ref(:amount) + row_2.ref(:amount)
cell_diff = row_1.ref(:amount) - row_2.ref(:amount)
cell_product = row_1.ref(:amount) * row_2.ref(:amount)
cell_quotient = row_1.ref(:amount) / row_2.ref(:amount)

# Excel functions
sum_formula = Zaxcel::Functions.sum(
  Zaxcel::Lang.range(row_1.ref(:amount), row_10.ref(:amount))
)
average_formula = Zaxcel::Functions::Average.new(
  Zaxcel::Lang.range(row_1.ref(:amount), row_10.ref(:amount))
)
max_formula = Zaxcel::Functions.max(
  Zaxcel::Lang.range(row_1.ref(:amount), row_10.ref(:amount))
)
min_formula = Zaxcel::Functions.min(
  Zaxcel::Lang.range(row_1.ref(:amount), row_10.ref(:amount))
)

# Conditional formulas
if_formula = Zaxcel::Lang
  .if(row_1.ref(:amount) > 100)
  .then('High')
  .else('Low')

# Rounding
rounded = Zaxcel::Functions.round(row_1.ref(:amount), precision: 2)
```

### Cross-Sheet References

One of Zaxcel's strengths is making cross-sheet references easy:

```ruby
document = Zaxcel::Document.new

# Create first sheet with data
data_sheet = document.add_sheet!('Data')
data_sheet.add_column!(:category)
data_sheet.add_column!(:value)

row_1 = data_sheet.add_row!(:row_1)
  .add!(:category, value: 'Sales')
  .add!(:value, value: 1000)

# Create summary sheet that references the data sheet
summary_sheet = document.add_sheet!('Summary')
summary_sheet.add_column!(:description)
summary_sheet.add_column!(:amount)

summary_sheet.add_row!(:sales_summary)
  .add!(:description, value: 'Total Sales')
  .add!(:amount, data_sheet.cell_ref(:value, :row_1))

# Position and generate all sheets at once (after all content is added)
# This allows bidirectional references between sheets
document.sheet_by_name.values.each do |sheet|
  sheet.position_rows!
  sheet.generate_sheet!
end
```

### Styling

Apply styles to cells and columns:

```ruby
# Define styles
document.add_style!(:header, {
  bg_color: '0066CC',
  fg_color: 'FFFFFF',
  b: true,
  alignment: { horizontal: :center }
})

document.add_style!(:currency, {
  format_code: '$#,##0.00'
})

document.add_style!(:percentage, {
  format_code: '0.00%'
})

# Apply to cells
sheet.add_row!(:header)
  .add!(:name, value: 'Product', style: :header)
  .add!(:price, value: 'Price', style: :header)

sheet.add_row!(:product_1)
  .add!(:name, value: 'Widget')
  .add!(:price, value: 19.99, style: :currency)
```

### Column Configuration

Configure column widths and other properties:

```ruby
sheet.add_column!(:narrow, width: 10)
sheet.add_column!(:wide, width: 30)
sheet.add_column!(:auto, width: nil)  # Let caxlsx auto-calc width from contents

# Or use computed widths
sheet.add_column!(
  :fit_header,
  width: Zaxcel::Column::ComputedColumnWidth::Header,
)
sheet.add_column!(
  :fit_content,
  width: Zaxcel::Column::ComputedColumnWidth::MaxContent,
)
```

### Advanced Features

#### SUMIF and SUMIFS

```ruby
# Sum values where a condition is met
sum_if = Zaxcel::Functions.sum_if(
  column_to_check: category_column,
  value_to_check: 'Sales',
  column_to_sum: amount_column,
)

# Sum with multiple conditions
sum_ifs = Zaxcel::Functions.sum_ifs(
  ranges_to_check: [
    Zaxcel::Lang.range(category_column),
    Zaxcel::Lang.range(region_column),
  ],
  values_to_check: ['Sales', 'West'],
  range_to_sum: Zaxcel::Lang.range(amount_column),
)
```

#### XLOOKUP and INDEX/MATCH

```ruby
# Modern XLOOKUP
lookup = Zaxcel::Functions.x_lookup(
  'Product A',
  idx_range: Zaxcel::Lang.range(product_column),
  value_range: Zaxcel::Lang.range(price_column),
)

# Traditional INDEX/MATCH
match = Zaxcel::Functions.match(
  value: 'Product A',
  range: Zaxcel::Lang.range(product_column),
  match_type: Zaxcel::Functions::Match::MatchType::EXACT,
)

index = Zaxcel::Functions.index(
  index_value: match,
  range: price_column,
)
```

#### Conditional Logic

```ruby
# Build conditional logic
status = Zaxcel::Lang
  .if(row.ref(:amount) > 1000)
  .then('High')
  .else('Low')
```

### Sheet Visibility

Control whether sheets are visible:

```ruby
# Create a hidden sheet
hidden_sheet = document.add_sheet!(
  'Calculations',
  sheet_visibility: Zaxcel::Sheet::SheetVisibility::Hidden
)

# Create a visible sheet (default)
visible_sheet = document.add_sheet!(
  'Report',
  sheet_visibility: Zaxcel::Sheet::SheetVisibility::Visible
)
```

## API Documentation

### Core Classes

#### `Zaxcel::Document`

The main container for your Excel workbook.

- `new(width_units_by_default_character: Float)` - Create a new document
- `add_sheet!(name, sheet_visibility: SheetVisibility)` - Add a new worksheet
- `add_style!(name, **kwargs)` - Define a named style
- `sheet(name)` - Get a sheet by name
- `file_contents` - Get the binary Excel file content

#### `Zaxcel::Sheet`

Represents a worksheet within the document.

- `add_column!(name, width: nil)` - Add a column (use `nil` for auto width; or `Zaxcel::Column::ComputedColumnWidth`)
- `add_row!(name, style_group: nil)` - Add a row
- `cell_ref(row_name, col_name, sheet_name: nil)` - Get a reference to a cell
- `position_rows!` then `generate_sheet!` - Finalize the sheet (call before writing)

#### `Zaxcel::Row`

Represents a row within a sheet.

- `add!(column_name, value:, style: nil, to_extract: false)` - Add a cell value
- `add_many!(hash)` - Add multiple cells at once
- `ref(column_name)` - Get a reference to a cell in this row

#### `Zaxcel::Column`

Represents a column within a sheet.

### Functions Module

All Excel functions are available under `Zaxcel::Functions`:

- `abs(value)` - Absolute value
- `sum(*values_or_ranges)` - Sum values and/or ranges
- `sum_range([first_ref, last_ref])` - Sum a contiguous range (convenience)
- `sum_if(column_to_check:, value_to_check:, column_to_sum:)`
- `sum_ifs(ranges_to_check:, values_to_check:, range_to_sum:)`
- `average(range)` - Average of a contiguous range
- `max(*values_or_ranges)` - Maximum value
- `min(*values_or_ranges)` - Minimum value
- `round(value, precision:)` - Round to decimal places
- `and(lhs, rhs)` / `or(lhs, rhs)` - Logical operations
- `concatenate(*values)` - Join strings
- `text(value, format_string:)` - Format value as text
- `len(value)` - String length
- `x_lookup(condition, idx_range:, value_range:)`
- `index(index_value:, range:)`
- `match(value:, range:, match_type:)` with `MatchType::EXACT`, `LESS_THAN_OR_EQUAL`, `GREATER_THAN_OR_EQUAL`

## Development

After checking out the repo, run:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

Run type checking:

```bash
bundle exec srb tc
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/angellist/zaxcel.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by the engineering team at [AngelList](https://www.angellist.com).

Built on top of the excellent [caxlsx](https://github.com/caxlsx/caxlsx) library.
