# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING CHANGE**: Renamed gem from `validator` to `validator_rb`
- **BREAKING CHANGE**: Renamed main module from `Validator` to `ValidatorRb`
- Updated all file paths and require statements to reflect the new name

### Added
- **IntegerValidator** with comprehensive numeric validation:
  - Range validators: `min`, `max`, `between`, `greater_than`, `less_than`
  - Sign validators: `positive`, `negative`, `non_negative`, `non_positive`
  - Divisibility validators: `multiple_of`, `even`, `odd`
  - Coercion support from strings and floats
  - Custom error messages for all validators
- Custom error messages for all validators via `message:` parameter
- Transformation methods: `trim`, `lowercase`, `uppercase`
- New string validators:
  - `length(n)` - exact length validation
  - `url` - URL format validation
  - `regex(pattern)` - custom regex pattern matching
  - `alphanumeric` - alphanumeric-only validation
  - `alpha` - alphabetic-only validation
  - `numeric_string` - numeric-only validation
  - `starts_with(prefix)` - prefix validation
  - `ends_with(suffix)` - suffix validation
- Convenience shortcuts:
  - `non_empty_string` - combines required, trim, and non_empty
  - `trimmed_email` - combines trim, lowercase, and email
- `Result#value` attribute to access transformed values
- Comprehensive test suite (137 tests with 100% coverage)

### Changed
- Enhanced `BaseValidator` with transformation support
- Result object now includes transformed value
- Updated all documentation with new features

## [0.1.0] - 2025-12-07

### Added
- Initial release
- Basic string validators: `min`, `max`, `email`, `non_empty`
- Required/optional field support
- Fluent chainable API
- Result object with success/failure methods
