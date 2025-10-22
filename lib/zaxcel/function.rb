# frozen_string_literal: true
# typed: strict

# Functions don't have any special interface beyond cell formulas, but it's useful to be able to detect them since they
# interact with other cell formulas in their own way.
class Zaxcel::Function < Zaxcel::CellFormula; end
