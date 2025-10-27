# Zaxcel Quick Start Guide

Get started with Zaxcel in 5 minutes!

## Installation

```bash
cd zaxcel_gem
bundle install
```

## Your First Spreadsheet

Create a file called `my_first_sheet.rb`:

```ruby
require 'bundler/setup'
require 'zaxcel'

# Create a document
document = Zaxcel::Document.new
sheet = document.add_sheet!('My Sheet')

# Add columns
sheet.add_column!(:name)
sheet.add_column!(:age)

# Add rows
sheet.add_row!(:person1)
  .add!(:name, value: 'Alice')
  .add!(:age, value: 30)

sheet.add_row!(:person2)
  .add!(:name, value: 'Bob')
  .add!(:age, value: 25)

# Position and generate sheet (after all content is added)
sheet.position_rows!
sheet.generate_sheet!
File.write('people.xlsx', document.file_contents)

puts "Created people.xlsx!"
```

Run it:

```bash
ruby my_first_sheet.rb
```

Open `people.xlsx` in Excel or LibreOffice!

## Adding Formulas

Let's add some calculations:

```ruby
require 'bundler/setup'
require 'zaxcel'

document = Zaxcel::Document.new
sheet = document.add_sheet!('Math')

sheet.add_column!(:label)
sheet.add_column!(:value)

# Add some numbers
row1 = sheet.add_row!(:num1).add!(:label, value: 'First').add!(:value, value: 10)
row2 = sheet.add_row!(:num2).add!(:label, value: 'Second').add!(:value, value: 20)

# Add a sum formula
sheet.add_row!(:total)
  .add!(:label, value: 'Total')
  .add!(:value, row1.ref(:value) + row2.ref(:value))

# Position and generate sheet (after all content is added)
sheet.position_rows!
sheet.generate_sheet!
File.write('math.xlsx', document.file_contents)
```

## Styling Cells

Add some color:

```ruby
require 'bundler/setup'
require 'zaxcel'

document = Zaxcel::Document.new

# Define a style
document.add_style!(:header, {
  bg_color: '0066CC',
  fg_color: 'FFFFFF',
  b: true
})

sheet = document.add_sheet!('Styled')
sheet.add_column!(:category)

# Use the style
sheet.add_row!(:header)
  .add!(:category, value: 'Category', style: :header)

sheet.add_row!(:data)
  .add!(:category, value: 'Data')

# Position and generate sheet (after all content is added)
sheet.position_rows!
sheet.generate_sheet!
File.write('styled.xlsx', document.file_contents)
```

## Try the Examples

Check out the `examples/` directory for more:

```bash
ruby examples/basic_spreadsheet.rb
ruby examples/cross_sheet_references.rb
```

## Next Steps

- Read the full [README.md](README.md) for comprehensive documentation
- Browse example code in `examples/`
- Check out the test suite in `spec/` for more usage patterns
- Try building your own spreadsheets!

## Common Patterns

### Building a Report

```ruby
# Create document
document = Zaxcel::Document.new
sheet = document.add_sheet!('Report')

# Set up columns
[:date, :description, :amount].each { |col| sheet.add_column!(col) }

# Add data
data = [
  { date: '2025-01-01', description: 'Sale', amount: 100 },
  { date: '2025-01-02', description: 'Purchase', amount: -50 }
]

data.each_with_index do |item, i|
  sheet.add_row!(:"row_#{i}")
    .add!(:date, value: item[:date])
    .add!(:description, value: item[:description])
    .add!(:amount, value: item[:amount])
end

# Position and generate sheet (after all content is added)
sheet.position_rows!
sheet.generate_sheet!
```

### Using Functions

```ruby
# Sum a range
sum = Zaxcel::Functions.sum_range([first_row.ref(:amount), last_row.ref(:amount)])

# Average
avg = Zaxcel::Functions::Average.new(values)

# Conditional
status = Zaxcel::Functions::If.new(
  condition: row.ref(:amount) > 100,
  true_value: 'High',
  false_value: 'Low'
)

# Round
rounded = Zaxcel::Functions.round(value, precision: 2)
```

## Need Help?

- Check [README.md](README.md) for full documentation
- Look at [examples/](examples/) for working code
- Open an issue on GitHub

Happy spreadsheet building! 📊
