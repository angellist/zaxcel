# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Functions::If do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('calc')

    calc_sheet.add_column!(:small)
    calc_sheet.add_column!(:bigger)
    calc_sheet.add_column!(:biggest)

    calc_sheet.add_row!(:integers)
      .add!(:small, value: 0)
      .add!(:bigger, value: 1)
      .add!(:biggest, value: 100)

    calc_sheet.add_row!(:spoken)
      .add!(:small, value: 'small')
      .add!(:bigger, value: 'bigger')
      .add!(:biggest, value: 'biggest')

    calc_sheet
  end

  context 'with numbers only formatting correct for' do
    # LT(E)
    #
    it 'lt' do
      formula = described_class.new(
        Zaxcel::BinaryExpressions.less_than(0, 1),
        if_true: 10,
        if_false: -10,
      )
      expect(formula.format(on_sheet: sheet)).to eq('IF(0<1,10,-10)')
    end

    it 'lte' do
      formula = Zaxcel::Lang.if(Zaxcel::BinaryExpressions.less_than_equal(1, 1))
        .then(10)
        .else(-10)
      expect(formula.format(on_sheet: sheet)).to eq('IF(1<=1,10,-10)')
    end

    # GT(E)
    #
    it 'gt' do
      formula = described_class.new(
        Zaxcel::BinaryExpressions.greater_than(2, 1),
        if_true: 10,
        if_false: -10,
      )
      expect(formula.format(on_sheet: sheet)).to eq('IF(2>1,10,-10)')
    end

    it 'gte' do
      formula = described_class.new(
        Zaxcel::BinaryExpressions.greater_than_equal(1, 1),
        if_true: 10,
        if_false: -10,
      )
      expect(formula.format(on_sheet: sheet)).to eq('IF(1>=1,10,-10)')
    end

    # EQ
    #
    it 'eq' do
      formula = described_class.new(
        Zaxcel::BinaryExpressions.equal(1, 1),
        if_true: 10,
        if_false: -10,
      )
      expect(formula.format(on_sheet: sheet)).to eq('IF(1=1,10,-10)')
    end
  end

  it 'can compare formulas' do
    formula = described_class.new(
      Zaxcel::BinaryExpressions.equal(
        Zaxcel::BinaryExpression.new('+', 1, 2),
        Zaxcel::BinaryExpression.new('+', 4, 9),
      ),
      if_true: 10,
      if_false: -10,
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(1+2=4+9,10,-10)')
  end

  it 'can return strings' do
    formula = described_class.new(
      Zaxcel::BinaryExpressions.equal(
        Zaxcel::BinaryExpression.new('+', 1, 2),
        Zaxcel::BinaryExpression.new('+', 4, 9),
      ),
      if_true: 'true-ness',
      if_false: 'false-ness',
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(1+2=4+9,"true-ness","false-ness")')
  end

  it 'can return date times' do
    lets_party_like_its = Time.new(1999, 12, 31)
    formula = described_class.new(
      Zaxcel::BinaryExpressions.equal(
        Zaxcel::BinaryExpression.new('+', 1, 2),
        Zaxcel::BinaryExpression.new('+', 4, 9),
      ),
      if_true: lets_party_like_its,
      if_false: lets_party_like_its + 1.day,
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(1+2=4+9,DATE(1999, 12, 31)+TIME(0, 0, 0),DATE(2000, 1, 1)+TIME(0, 0, 0))')
  end

  it 'can return dates' do
    lets_party_like_its = Date.new(1999, 12, 31)
    formula = described_class.new(
      Zaxcel::BinaryExpressions.equal(
        Zaxcel::BinaryExpression.new('+', 1, 2),
        Zaxcel::BinaryExpression.new('+', 4, 9),
      ),
      if_true: lets_party_like_its,
      if_false: lets_party_like_its + 1.day,
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(1+2=4+9,12/31/1999,01/01/2000)')
  end

  it 'can handle formulas in all positions' do
    formula = described_class.new(
      Zaxcel::BinaryExpressions.equal(
        Zaxcel::BinaryExpression.new('+', 1, 2),
        Zaxcel::BinaryExpression.new('+', 4, 9),
      ),
      if_true: Zaxcel::BinaryExpression.new('*', 1, 2),
      if_false: Zaxcel::BinaryExpression.new('*', 4, 9),
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(1+2=4+9,1*2,4*9)')
  end

  it 'can work with Money' do
    in_pocket = 3.675.to_money
    cost = 9.99.to_money
    formula = described_class.new(
      Zaxcel::BinaryExpressions.greater_than_equal(in_pocket, cost),
      if_true: 'buy it!',
      if_false: 'keep saving!',
    )
    expect(formula.format(on_sheet: sheet)).to eq('IF(3.68>=9.99,"buy it!","keep saving!")')
  end

  it 'can work with intra-sheet CellReferences' do
    formula = described_class.new(
      Zaxcel::BinaryExpressions.greater_than(
        sheet.cell_ref(:small, :integers),
        sheet.cell_ref(:bigger, :integers),
      ),
      if_true: sheet.cell_ref(:bigger, :spoken),
      if_false: sheet.cell_ref(:small, :spoken),
    )

    sheet.position_rows!

    expect(formula.format(on_sheet: sheet.name)).to eq('IF(A1>B1,B2,A2)')
  end

  it 'can work with inter-sheet CellReferences' do
    formula = described_class.new(
      Zaxcel::BinaryExpressions.greater_than(
        sheet.cell_ref(:small, :integers),
        sheet.cell_ref(:bigger, :integers),
      ),
      if_true: sheet.cell_ref(:bigger, :spoken),
      if_false: sheet.cell_ref(:small, :spoken),
    )

    sheet.position_rows!

    ref_prefix = "'#{sheet.name}'!"
    expect(formula.format(on_sheet: 'elsewhere')).to eq("IF(#{ref_prefix}A1>#{ref_prefix}B1,#{ref_prefix}B2,#{ref_prefix}A2)")
  end
end
