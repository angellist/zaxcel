#!/usr/bin/env ruby
# typed: strict
# frozen_string_literal: true

# Basic example of creating a simple spreadsheet with Zaxcel

require 'bundler/setup'
require 'zaxcel'

# Create a new document
document = Zaxcel::Document.new
sheet = document.add_sheet!('Monthly Sales')

# Add columns
sheet.add_column!(:month, header: 'Month', header_style: :header)
sheet.add_column!(:sales, header: 'Sales', header_style: :header)
sheet.add_column!(:expenses, header: 'Expenses', header_style: :header)
sheet.add_column!(:profit, header: 'Profit', header_style: :header)

# Define styles
document.add_style!(
  :header,
  bg_color: '366092',
  fg_color: 'FFFFFF',
  b: true,
  alignment: { horizontal: :center }
)

document.add_style!(
  :currency,
  format_code: '$#,##0.00'
)

document.add_style!(
  :total,
  b: true,
  format_code: '$#,##0.00',
  bg_color: 'E7E6E6'
)

# Add header row
sheet.add_column_header_row!

# Add data rows with formulas
data = [
  { month: 'January', sales: 50_000, expenses: 30_000 },
  { month: 'February', sales: 55_000, expenses: 32_000 },
  { month: 'March', sales: 60_000, expenses: 35_000 },
  { month: 'April', sales: 58_000, expenses: 33_000 }
]

rows = []
data.each_with_index do |item, index|
  row = sheet.add_row!(:"month_#{index + 1}")
             .add!(:month, value: item[:month])
             .add!(:sales, value: item[:sales], style: :currency)
             .add!(:expenses, value: item[:expenses], style: :currency)

  # Profit = Sales - Expenses (formula)
  row.add!(:profit, value: row.ref(:sales) - row.ref(:expenses), style: :currency)
  rows << row
end

# Add total row
total_row = sheet.add_row!(:total)
                 .add!(:month, value: 'TOTAL', style: :total)

# Sum all sales
total_row.add!(
  :sales,
  value: Zaxcel::Functions.sum(Zaxcel::Lang.range(rows.first!.ref(:sales), rows.last!.ref(:sales))),
  style: :total
)

# Sum all expenses
total_row.add!(
  :expenses,
  value: Zaxcel::Functions.sum(Zaxcel::Lang.range(rows.first!.ref(:expenses), rows.last!.ref(:expenses))),
  style: :total
)

# Sum all profit
total_row.add!(
  :profit,
  value: Zaxcel::Functions.sum(Zaxcel::Lang.range(rows.first!.ref(:profit), rows.last!.ref(:profit))),
  style: :total
)

# Position rows before generating so references resolve
sheet.position_rows!
sheet.generate_sheet!

# Ensure Excel forces a full recalc on load
sheet.unsafe_axlsx_worksheet.sheet_calc_pr.full_calc_on_load = true

# Write to file (binary-safe)
filename = 'monthly_sales.xlsx'
data = document.file_contents
File.write(filename, data, mode: 'wb')
puts "Spreadsheet created: #{filename}"
