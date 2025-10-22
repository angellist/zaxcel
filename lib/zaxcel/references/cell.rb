# frozen_string_literal: true
# typed: strict

class Zaxcel::References::Cell < Zaxcel::Reference
  include Zaxcel::Arithmetic
  include Zaxcel::Roundable
  extend T::Sig

  sig { override.returns(String) }
  attr_reader :sheet_name

  sig { returns(Zaxcel::Document) }
  attr_reader :document

  sig { returns(Symbol) }
  attr_reader :column_name, :row_name

  sig { params(document: Zaxcel::Document, sheet_name: String, row_name: Symbol, col_name: Symbol).void }
  def initialize(document:, sheet_name:, row_name:, col_name:)
    super()

    @document = document
    @sheet_name = sheet_name
    @column_name = col_name
    @row_name = row_name
  end

  sig { override.returns(String) }
  def resolve
    cell&.to_excel || ''
  end

  sig { override.returns(String) }
  def excel_sheet_name
    T.must(@document.sheet_by_name[@sheet_name]&.to_excel)
  end

  sig { returns(T.nilable(Zaxcel::Cell)) }
  def cell
    @document.sheet(@sheet_name)&.column(@column_name)&.cell(@row_name)
  end
end
