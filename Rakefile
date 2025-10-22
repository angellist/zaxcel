# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Run Sorbet type checker'
task :sorbet do
  sh 'bundle exec srb tc'
end

desc 'Run all checks (tests, linting, type checking)'
task checks: %i[spec rubocop sorbet]

task default: :checks
