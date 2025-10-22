# frozen_string_literal: true
# typed: strict

class Zaxcel::Reference
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { abstract.returns(String) }
  def sheet_name; end

  sig { abstract.returns(String) }
  def excel_sheet_name; end

  sig { abstract.returns(String) }
  def resolve; end

  sig { params(on_sheet: String).returns(T.nilable(String)) }
  def format(on_sheet:)
    formatted_string = resolve
    return if formatted_string.blank?

    formatted_string = "'#{excel_sheet_name}'!#{formatted_string}" if on_sheet.present? && on_sheet != sheet_name

    formatted_string
  end
end
