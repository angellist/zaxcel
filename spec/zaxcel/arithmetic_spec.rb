# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zaxcel::Arithmetic do
  let(:sheet) do
    doc = Zaxcel::Document.new
    calc_sheet = doc.add_sheet!('binary_expressions')

    calc_sheet.add_column!(:first)
    calc_sheet.add_column!(:last)

    calc_sheet.add_row!(:simple)
      .add!(:first, value: 0)
      .add!(:last, value: 1)

    calc_sheet
  end

  let(:a1_reference) { sheet.cell_ref(:first, :simple) }
  let(:b1_reference) { sheet.cell_ref(:last, :simple) }

  before do
    sheet.position_rows!
  end

  describe 'works with sums' do
    it 'const + ref' do
      formula = 1.2 + a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2+A1')
    end

    it '-const * ref' do
      formula = -1.2 + a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('-1.2+A1')
    end

    it 'ref + const' do
      formula = a1_reference + 1.2
      expect(formula.format(on_sheet: sheet.name)).to eq('A1+1.2')
    end

    it 'ref * -const' do
      formula = 1.2 + -a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2+(-A1)')
    end

    it 'ref + ref' do
      formula = a1_reference + b1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('A1+B1')
    end

    it 'ref + Zaxcel::Arithmetic.zero' do
      expect((a1_reference + described_class.zero).format(on_sheet: sheet.name)).to eq('A1')
    end

    it 'Zaxcel::Arithmetic.zero + ref' do
      expect((described_class.zero + a1_reference).format(on_sheet: sheet.name)).to eq('A1')
    end

    it 'numeric + Zaxcel::Arithmetic.zero' do
      expect((1.2 + described_class.zero).format(on_sheet: sheet.name)).to eq(1.2)
    end

    it 'Zaxcel::Arithmetic.zero + numeric' do
      expect((described_class.zero + 1.2).format(on_sheet: sheet.name)).to eq(1.2)
    end

    context 'with Array#sum' do
      it 'Array#sum leads with a zero' do
        formula = [a1_reference, b1_reference, 1.2]
        expect(formula.sum.format(on_sheet: sheet.name)).to eq('0+A1+B1+1.2')
      end

      it 'works with Array#sum when initialized with zero' do
        formula = [a1_reference, b1_reference, 1.2]
        expect(formula.sum(described_class.zero).format(on_sheet: sheet.name)).to eq('A1+B1+1.2')
      end

      it 'works with Array#sum when initialized with zero and first element is a numeric' do
        formula = [1.2, a1_reference, b1_reference]
        expect(formula.sum(described_class.zero).format(on_sheet: sheet.name)).to eq('1.2+A1+B1')
      end
    end
  end

  describe 'works with subtraction' do
    it 'const - ref' do
      formula = 1.2 - a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2-A1')
    end

    it '-const - ref' do
      formula = -1.2 - a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('-1.2-A1')
    end

    it 'ref - const' do
      formula = a1_reference - 1.2
      expect(formula.format(on_sheet: sheet.name)).to eq('A1-1.2')
    end

    it 'ref - -const' do
      formula = 1.2 - -a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2-(-A1)')
    end

    it 'ref - ref' do
      formula = a1_reference - b1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('A1-B1')
    end

    it 'ref - Zaxcel::Arithmetic.zero' do
      expect((a1_reference - described_class.zero).format(on_sheet: sheet.name)).to eq('A1')
    end

    it 'Zaxcel::Arithmetic.zero - ref' do
      expect((described_class.zero - a1_reference).format(on_sheet: sheet.name)).to eq('-A1')
    end

    it 'numeric - Zaxcel::Arithmetic.zero' do
      expect((1.2 - described_class.zero).format(on_sheet: sheet.name)).to eq(1.2)
    end

    it 'Zaxcel::Arithmetic.zero - numeric' do
      expect((described_class.zero - 1.2).format(on_sheet: sheet.name)).to eq(-1.2)
    end
  end

  describe 'works with products' do
    it 'const * ref' do
      formula = 1.2 * a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2*A1')
    end

    it '-const * ref' do
      formula = -1.2 * a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('-1.2*A1')
    end

    it 'ref * const' do
      formula = a1_reference * 1.2
      expect(formula.format(on_sheet: sheet.name)).to eq('A1*1.2')
    end

    it 'ref * -const' do
      formula = 1.2 * -a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2*(-A1)')
    end

    it 'ref * ref' do
      formula = a1_reference * b1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('A1*B1')
    end
  end

  describe 'works with divison' do
    it 'const / ref' do
      formula = 1.2 / a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2/A1')
    end

    it '-const / ref' do
      formula = -1.2 / a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('-1.2/A1')
    end

    it 'ref / const' do
      formula = a1_reference / 1.2
      expect(formula.format(on_sheet: sheet.name)).to eq('A1/1.2')
    end

    it 'ref / -const' do
      formula = 1.2 / -a1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('1.2/(-A1)')
    end

    it 'ref / ref' do
      formula = a1_reference / b1_reference
      expect(formula.format(on_sheet: sheet.name)).to eq('A1/B1')
    end
  end

  it 'handles associativity correctly' do
    formula = 1.2 - (3 * (a1_reference + (4 / b1_reference)))
    expect(formula.format(on_sheet: sheet.name)).to eq('1.2-3*(A1+4/B1)')

    formula = (((1.2 - 3) * a1_reference) + 4) / b1_reference
    expect(formula.format(on_sheet: sheet.name)).to eq('(-1.8*A1+4)/B1')

    formula = 1.2 - 3 * (a1_reference + 4) / b1_reference
    expect(formula.format(on_sheet: sheet.name)).to eq('1.2-3*(A1+4)/B1')
  end
end
