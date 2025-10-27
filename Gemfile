# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in zaxcel.gemspec
gemspec

gem 'pry', '~> 0.14'
gem 'simplecov', '~> 0.22', require: false

group :development do
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3')
    gem 'rubocop-angellist', github: 'angellist/rubocop-angellist'
  end
end
