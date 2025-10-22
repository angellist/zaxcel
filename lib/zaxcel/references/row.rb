# frozen_string_literal: true
# typed: strict

class Zaxcel::References::Row < Zaxcel::Reference
  extend T::Sig

  sig { override.returns(String) }
  attr_reader :sheet_name

  sig { params(sheet_name: String, row_name: Symbol, document: Zaxcel::Document).void }
  def initialize(sheet_name:, row_name:, document:)
    super()

    @sheet_name = sheet_name
    @row_name = row_name
    @document = document
  end

  sig { override.returns(String) }
  def resolve
    T.must_because(row) { "No row on sheet #{sheet_name} named #{@row_name}" }
      .to_excel
  end

  sig { override.returns(String) }
  def excel_sheet_name
    T.must(@document.sheet_by_name[@sheet_name]&.to_excel)
  end

  sig { returns(T.nilable(Zaxcel::Row)) }
  def row
    @row ||= T.let(@document.sheet(sheet_name)&.row(@row_name), T.nilable(Zaxcel::Row))
  end
end
