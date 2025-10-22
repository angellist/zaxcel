#!/usr/bin/env ruby
# typed: strict
# frozen_string_literal: true

# Example demonstrating cross-sheet references in Zaxcel

require 'bundler/setup'
require 'zaxcel'

document = Zaxcel::Document.new

# Create a data sheet with product information
data_sheet = document.add_sheet!('Product Data')
data_sheet.add_column!(:product, header: 'Product', header_style: :header)
data_sheet.add_column!(:unit_price, header: 'Unit Price', header_style: :header)
data_sheet.add_column!(:stock, header: 'Stock', header_style: :header)

document.add_style!(:header, b: true, bg_color: 'CCCCCC')
document.add_style!(:currency, format_code: '$#,##0.00')

data_sheet.add_column_header_row!

products = [
  { name: 'Widget A', price: 10.50, stock: 100 },
  { name: 'Widget B', price: 15.75, stock: 75 },
  { name: 'Gadget X', price: 25.00, stock: 50 },
  { name: 'Gadget Y', price: 30.25, stock: 25 }
]

product_rows = []
products.each do |product|
  row = data_sheet.add_row!(product[:name])
                  .add!(:product, value: product[:name])
                  .add!(:unit_price, value: product[:price], style: :currency)
                  .add!(:stock, value: product[:stock])
  product_rows << row
end

data_sheet.position_rows!
data_sheet.generate_sheet!

# Create a summary sheet that references the data sheet
summary_sheet = document.add_sheet!('Summary')
summary_sheet.add_column!(:metric, header: 'Metric', header_style: :header)
summary_sheet.add_column!(:value, header: 'Value', header_style: :header)
summary_sheet.add_column_header_row!

# Total inventory value = SUM(price * stock) for all products
inventory_formula = product_rows.sum(Zaxcel::Arithmetic.zero) do |row|
  data_sheet.cell_ref(:unit_price, row.name) * data_sheet.cell_ref(:stock, row.name)
end

summary_sheet.add_row!(:total_inventory)
             .add!(:metric, value: 'Total Inventory Value')
             .add!(:value, value: inventory_formula, style: :currency)

# Average product price
avg_price = Zaxcel::Functions::Average.new(
  Zaxcel::Lang.range(
    data_sheet.cell_ref(:unit_price, products.first[:name]),
    data_sheet.cell_ref(:unit_price, products.last[:name])
  )
)

summary_sheet.add_row!(:avg_price)
             .add!(:metric, value: 'Average Product Price')
             .add!(:value, value: avg_price, style: :currency)

# Total stock units
total_stock = Zaxcel::Functions.sum(
  Zaxcel::Lang.range(
    data_sheet.cell_ref(:stock, products.first[:name]),
    data_sheet.cell_ref(:stock, products.last[:name])
  )
)

summary_sheet.add_row!(:total_stock)
             .add!(:metric, value: 'Total Stock Units')
             .add!(:value, value: total_stock)

# Most expensive product
max_price = Zaxcel::Functions::Max.new(
  [
    Zaxcel::Lang.range(
      data_sheet.cell_ref(:unit_price, products.first[:name]),
      data_sheet.cell_ref(:unit_price, products.last[:name])
    )
  ]
)

summary_sheet.add_row!(:max_price)
             .add!(:metric, value: 'Highest Price')
             .add!(:value, value: max_price, style: :currency)

summary_sheet.position_rows!
summary_sheet.generate_sheet!

# Write to file (binary-safe via Tempfile)
filename = 'cross_sheet_example.xlsx'
data = document.file_contents
raise 'Document had no contents' if data.nil?

File.write(filename, data, mode: 'wb')

puts "Spreadsheet with cross-sheet references created: #{filename}"
