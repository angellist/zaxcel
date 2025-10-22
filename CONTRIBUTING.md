# Contributing to Zaxcel

Thank you for considering contributing to Zaxcel! This document outlines the process for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to engineering@angellist.com.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

* A clear and descriptive title
* Detailed steps to reproduce the problem
* Expected behavior
* Actual behavior
* Ruby version and gem version
* Any relevant code samples or test cases

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

* A clear and descriptive title
* A detailed description of the proposed functionality
* Examples of how the feature would be used
* Any relevant implementation details

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes (`bundle exec rspec`)
5. Ensure type checking passes (`bundle exec srb tc`)
6. Make sure your code follows the existing style (run `bundle exec rubocop`)
7. Write a clear commit message

## Development Setup

```bash
git clone https://github.com/angellist/zaxcel.git
cd zaxcel
bundle install
bundle exec rspec
```

## Type Checking with Sorbet

This project uses Sorbet for type safety. Please ensure all new code includes type signatures:

```ruby
extend T::Sig

sig { params(name: String).returns(Integer) }
def my_method(name)
  # implementation
end
```

Run type checking with:

```bash
bundle exec srb tc
```

## Testing Guidelines

* Write RSpec tests for all new functionality
* Aim for high test coverage
* Test both success and error cases
* Include integration tests for complex features

## Style Guide

This project follows standard Ruby style guidelines enforced by RuboCop. Run:

```bash
bundle exec rubocop
```

To auto-correct issues:

```bash
bundle exec rubocop -a
```

## Documentation

* Update README.md for user-facing changes
* Add YARD comments for new public methods
* Update CHANGELOG.md following Keep a Changelog format

## Release Process

(For maintainers)

1. Update version in `lib/zaxcel.rb`
2. Update CHANGELOG.md with release date
3. Create a git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. Build gem: `gem build zaxcel.gemspec`
6. Push to RubyGems: `gem push zaxcel-1.0.0.gem`

## Questions?

Feel free to open an issue for questions or discussion!

