# Zaxcel Examples

This directory contains example scripts demonstrating various features of Zaxcel.

## Running Examples

Make sure you have the gem installed:

```bash
# From the gem root directory
bundle install
```

Then run any example (with Bundler):

```bash
bundle exec ruby examples/basic_spreadsheet.rb
bundle exec ruby examples/cross_sheet_references.rb
```

## Available Examples

### basic_spreadsheet.rb

A simple monthly sales report demonstrating:

- Creating sheets and columns
- Adding styled header rows
- Using formulas for calculations (profit = sales - expenses)
- Summing columns with `SUM` function
- Currency formatting
- Bold and colored cells

Output: `monthly_sales.xlsx`

### cross_sheet_references.rb

A more complex example showing:

- Multiple sheets in one document
- Cross-sheet cell references
- Using various functions: `SUM`, `AVERAGE`, `MAX`
- Referencing cells from another sheet
- Calculating derived metrics

Output: `cross_sheet_example.xlsx`

## Creating Your Own Examples

Feel free to create additional examples! A good example should:

1. Be self-contained and runnable
2. Demonstrate specific features clearly
3. Include comments explaining what's happening
4. Generate an output file that can be opened in Excel/LibreOffice
5. Be less than 150 lines of code

## Example Template

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Brief description of what this example demonstrates

require 'bundler/setup'
require 'zaxcel'

# Your code here
document = Zaxcel::Document.new
# ...

# Write output
filename = 'output.xlsx'
data = document.file_contents
raise 'Document had no contents' if data.nil?
File.write(filename, data, mode: 'wb')
puts "Spreadsheet created: #{filename}"
```
