# Zaxcel (Zach's Excel)

Zaxcel is a ruby library built on top of (c)axlsx that adds an abstraction layer to building excel documents. It add simple methods for building formulas and references to other cells, even across many worksheets.

  * The goal of Zaxcel is to enable building excel sheets in a ruby idiomatic DSL without having to think about the underlying excel. We want to interact with purely Ruby objects in a purely Ruby way while building excel sheets.
  * Reimplementing Excel in Ruby is an explicit anti-goal.

### How to use Zaxcel

```ruby
document = Zaxcel::Document.new
my_sheet = document.add_sheet!('my_sheet')

my_sheet.add_column!(:column_1)
my_sheet.add_column!(:column_2)

row_1 = my_sheet.add_row!(:row_1).add!(:column_1, value: 'Row 1').add!(:column_2, value: 99)
row_2 = my_sheet.add_row!(:row_2).add!(:column_1, value: 'Row 2').add!(:column_2, value: 1)
my_sheet.add_row!(:total).add!(:column_1, value: 'Total').add!(:column_2, row_1.ref(:column_2) + row_2.ref(:column_2))

my_sheet.generate_sheet!

file = Tempfile.new('my_file.xlsx', encoding: 'ASCII-8BIT')
file.write(document.file_contents)
file.close
```

### Todo

1. Implement more expressive methods to eliminate unnecessary typing.
   `(row.ref(:fair_value) / end_balances_cell).round(precision: 4)`
2. More expressive styling apis.
3. Different underlying implementations.
   Right now we use CAXLSX to "print" excel sheets. But there's no reason we couldn't use google sheets or excel api under the hood to print direct to other end sources.
4. Can we read sheets into Zaxcel in a reasonable way?
5. clean up references api
6. Launch gem!
