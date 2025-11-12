# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2] - 2025-11-12

### Changed

- Updated development Ruby version to 3.4.0
- Upgraded Tapioca to ~> 0.17 for Ruby 3.4 compatibility

### Removed

- Removed `lib/zaxcel/README.md`. Documentation is centralized in the root `README.md`.

## [0.1.1] - 2025-10-29

### Changed

- Updated specs

## [0.1.0] - 2025-10-29

### Added

- Initial public release
- Core DSL for building Excel documents
- Support for cross-sheet references
- Formula building with Ruby operators
- Comprehensive Excel function library (SUM, SUMIF, SUMIFS, XLOOKUP, etc.)
- Cell styling and formatting
- Sheet visibility controls
- Column width configuration
- Type safety with Sorbet

[0.1.0]: https://github.com/angellist/zaxcel/releases/tag/v0.1.0
[0.1.1]: https://github.com/angellist/zaxcel/releases/tag/v0.1.1
[0.1.2]: https://github.com/angellist/zaxcel/releases/tag/v0.1.2
[Unreleased]: https://github.com/angellist/zaxcel/compare/v0.1.2...HEAD
