# Zaxcel - Setup Guide for Open Sourcing

This directory contains a complete, standalone Ruby gem for Zaxcel that's ready to be open-sourced.

## What's Included

### Core Files
- `lib/zaxcel/` - All source code copied from the Venture codebase
- `lib/zaxcel.rb` - Main entry point with proper requires
- `zaxcel.gemspec` - Gem specification with dependencies
- `Gemfile` - Development dependencies
- `Rakefile` - Build and test tasks

### Documentation
- `README.md` - Comprehensive user documentation with examples
- `CHANGELOG.md` - Version history (template)
- `CONTRIBUTING.md` - Contribution guidelines
- `LICENSE` - MIT License
- `SETUP.md` - This file

### Testing
- `spec/spec_helper.rb` - RSpec configuration
- `spec/zaxcel/document_spec.rb` - Document tests
- `spec/zaxcel/functions_spec.rb` - Functions tests
- `.rspec` - RSpec configuration

### Examples
- `examples/basic_spreadsheet.rb` - Simple sales report example
- `examples/cross_sheet_references.rb` - Multi-sheet example

### Configuration
- `.gitignore` - Files to ignore in git
- `.rubocop.yml` - Ruby style configuration
- `sorbet/config` - Sorbet type checker configuration

### CI/CD
- `.github/workflows/ci.yml` - GitHub Actions for testing
- `.github/workflows/release.yml` - Automated gem publishing

## Steps to Open Source

### 1. Review and Approval (REQUIRED)
- [ ] Get legal approval from AngelList to open-source
- [ ] Verify no proprietary information or secrets in code
- [ ] Update LICENSE file if needed (currently MIT)
- [ ] Update copyright year and company name if needed

### 2. Create GitHub Repository
```bash
# On GitHub, create a new repository: angellist/zaxcel
# Then locally:
cd zaxcel_gem
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:angellist/zaxcel.git
git push -u origin main
```

### 3. Set Up Repository Settings
- Add repository description: "A Ruby DSL for building Excel spreadsheets programmatically"
- Add topics: ruby, excel, spreadsheet, caxlsx, dsl
- Set up branch protection for main
- Configure required status checks

### 4. Test Locally
```bash
cd zaxcel_gem
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec srb tc
```

### 5. Update Dependencies (Optional)
Review if you want to make any dependencies optional:
- `money` gem - Used in type definitions, could be made optional
- `activesupport` - Consider minimizing dependency or making optional

### 6. Set Up RubyGems Account
- Create account at https://rubygems.org if needed
- Get API key from account settings
- Add as GitHub secret: `RUBYGEMS_API_KEY`

### 7. Publish First Release
```bash
# Update version in lib/zaxcel.rb if needed
# Update CHANGELOG.md with release date

git tag -a v1.0.0 -m "First public release"
git push origin v1.0.0

# Or build and publish manually:
gem build zaxcel.gemspec
gem push zaxcel-1.0.0.gem
```

### 8. Post-Release Tasks
- [ ] Announce on Ruby Weekly
- [ ] Write blog post on AngelList engineering blog
- [ ] Share on social media
- [ ] Submit to Ruby Toolbox
- [ ] Monitor GitHub issues

### 9. Update Venture Codebase
After the gem is published, update the main Venture repository:

```ruby
# In Gemfile
gem 'zaxcel', '~> 1.0'
```

Then remove `lib/zaxcel/` from Venture.

## Before Publishing Checklist

- [ ] Legal approval obtained
- [ ] No secrets or proprietary code
- [ ] Tests pass locally
- [ ] Documentation is complete
- [ ] Examples work correctly
- [ ] LICENSE file is correct
- [ ] CHANGELOG is updated
- [ ] Version number is set
- [ ] GitHub repository created
- [ ] RubyGems account set up

## Testing the Gem Locally

To test the gem before publishing:

```bash
cd zaxcel_gem
gem build zaxcel.gemspec
gem install zaxcel-1.0.0.gem

# Try running examples
ruby examples/basic_spreadsheet.rb
ruby examples/cross_sheet_references.rb
```

## Potential Issues to Address

1. **ActiveSupport Dependency**: The gem currently requires ActiveSupport for methods like `try`, `blank?`, and `parameterize`. Consider either:
   - Keeping it as a dependency (simplest)
   - Implementing these methods internally
   - Making it optional

2. **Money Gem**: Used in type definitions but may not be essential. Consider making it optional.

3. **Sorbet RBI Files**: May need to generate RBI files for dependencies:
   ```bash
   bundle exec tapioca init
   bundle exec tapioca gems
   ```

4. **Documentation Site**: Consider setting up GitHub Pages for better documentation.

5. **Versioning**: Start with 1.0.0 or consider 0.1.0 for initial release.

## Maintenance Plan

After open-sourcing:
- Respond to issues within 48 hours
- Review PRs weekly
- Release bug fixes promptly
- Plan quarterly feature releases
- Keep dependencies updated

## Questions or Issues?

If you encounter any issues during the open-sourcing process, document them here or create issues in the repository.

## Contact

For questions about this gem: engineering@angellist.com

