# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require 'caxlsx'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/access'
require 'active_support/core_ext/string/inflections'
require 'money'

require_relative 'zaxcel/version'
require_relative 'zaxcel/sorbet/enumerizable_enum'
require_relative 'enumerable'

# Core classes
require_relative 'zaxcel/arithmetic'
require_relative 'zaxcel/roundable'
require_relative 'zaxcel/reference'
require_relative 'zaxcel/cell_formula'
require_relative 'zaxcel/binary_expression'
require_relative 'zaxcel/function'
require_relative 'zaxcel/if_builder'
require_relative 'zaxcel/lang'

# Binary expressions
require_relative 'zaxcel/binary_expressions'
require_relative 'zaxcel/binary_expressions/addition'
require_relative 'zaxcel/binary_expressions/subtraction'
require_relative 'zaxcel/binary_expressions/multiplication'
require_relative 'zaxcel/binary_expressions/division'

# References
require_relative 'zaxcel/references'
require_relative 'zaxcel/references/cell'
require_relative 'zaxcel/references/column'
require_relative 'zaxcel/references/row'
require_relative 'zaxcel/references/range'

# Functions
require_relative 'zaxcel/functions'
require_relative 'zaxcel/functions/abs'
require_relative 'zaxcel/functions/and'
require_relative 'zaxcel/functions/average'
require_relative 'zaxcel/functions/choose'
require_relative 'zaxcel/functions/concatenate'
require_relative 'zaxcel/functions/if'
require_relative 'zaxcel/functions/if_error'
require_relative 'zaxcel/functions/index'
require_relative 'zaxcel/functions/len'
require_relative 'zaxcel/functions/match'
require_relative 'zaxcel/functions/match/match_type'
require_relative 'zaxcel/functions/max'
require_relative 'zaxcel/functions/min'
require_relative 'zaxcel/functions/negate'
require_relative 'zaxcel/functions/or'
require_relative 'zaxcel/functions/round'
require_relative 'zaxcel/functions/sum'
require_relative 'zaxcel/functions/sum_if'
require_relative 'zaxcel/functions/sum_ifs'
require_relative 'zaxcel/functions/sum_product'
require_relative 'zaxcel/functions/text'
require_relative 'zaxcel/functions/unique'
require_relative 'zaxcel/functions/x_lookup'
require_relative 'zaxcel/functions/xirr'

# Main classes
require_relative 'zaxcel/cell'
require_relative 'zaxcel/column'
require_relative 'zaxcel/row'
require_relative 'zaxcel/sheet'
require_relative 'zaxcel/document'
