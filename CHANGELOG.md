# Changelog

All notable changes to this project will be documented in this file. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions
follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-07-21

### Added

- SwiftPM build-tool plugin for root-level String Catalogs.
- Public `L10n.<Catalog>.<symbol>` API generated at compile time.
- Native interpolation, plural, comment, and `Bundle.module` preservation via
  Apple's `xcstringstool`.
- Incremental one-command-per-catalog generation.
- Strict transformer tests and an end-to-end localization fixture.

[Unreleased]: https://github.com/Harry-KNIGHT/SwiftLocalizedGenerator/compare/0.1.0...HEAD
[0.1.0]: https://github.com/Harry-KNIGHT/SwiftLocalizedGenerator/releases/tag/0.1.0
