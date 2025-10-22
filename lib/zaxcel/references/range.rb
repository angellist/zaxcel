# frozen_string_literal: true
# typed: strict

class Zaxcel::References::Range < Zaxcel::Reference
  extend T::Sig

  RangeableType = T.type_alias { T.any(Zaxcel::References::Cell, Zaxcel::References::Row, Zaxcel::References::Column) }

  sig { params(lh_value: RangeableType, rh_value: T.nilable(RangeableType)).void }
  def initialize(lh_value, rh_value)
    super()

    rh_value ||= lh_value
    raise 'Ranges must be from cells on the same sheet' if lh_value.sheet_name != rh_value.sheet_name
    raise "Incompatible range values #{lh_value.class.name}:#{rh_value.class.name}" if lh_value.class != rh_value.class

    @lh_value = lh_value
    @rh_value = T.let(rh_value, RangeableType)
  end

  sig { override.returns(String) }
  def resolve
    "#{@lh_value.resolve}:#{@rh_value.resolve}"
  end

  sig { override.returns(String) }
  def excel_sheet_name
    @lh_value.excel_sheet_name
  end

  sig { override.returns(String) }
  def sheet_name
    @lh_value.sheet_name
  end
end
