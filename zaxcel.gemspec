# frozen_string_literal: true

require_relative 'lib/zaxcel/version'

Gem::Specification.new do |spec|
  spec.name          = 'zaxcel'
  spec.version       = Zaxcel::VERSION
  spec.authors       = ['AngelList Engineering']
  spec.email         = ['engineering@angellist.com']

  spec.summary       = 'A Ruby DSL for building Excel spreadsheets programmatically'
  spec.description   = <<~DESC
    Zaxcel is a Ruby library built on top of caxlsx that adds an abstraction layer#{' '}
    to building Excel documents. It provides simple methods for building formulas#{' '}
    and references to other cells, even across many worksheets, using a clean Ruby#{' '}
    idiom without having to think about the underlying Excel implementation.
  DESC
  spec.homepage      = 'https://github.com/angellist/zaxcel'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/angellist/zaxcel/issues',
    'changelog_uri' => 'https://github.com/angellist/zaxcel/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/angellist/zaxcel',
    'homepage_uri' => 'https://github.com/angellist/zaxcel',
    'source_code_uri' => 'https://github.com/angellist/zaxcel',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'caxlsx', '~> 4.0'
  spec.add_dependency 'money', '~> 6.0'
  spec.add_dependency 'sorbet-runtime', '~> 0.5'

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
  spec.add_development_dependency 'sorbet', '~> 0.5'
  spec.add_development_dependency 'tapioca', '~> 0.11'
end
