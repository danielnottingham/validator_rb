# Validator

A fluent, type-safe schema validation library for Ruby inspired by Zod. Build complex validations with chainable methods, custom error messages, and built-in transformations.

[![Ruby](https://img.shields.io/badge/ruby-3.2+-red.svg)](https://www.ruby-lang.org)
[![Tests](https://img.shields.io/badge/tests-78%20passing-success.svg)](spec/)
[![Coverage](https://img.shields.io/badge/coverage-100%25-success.svg)](coverage/)

## Features

✨ **Fluent API** - Chain validators for readable, expressive validation  
🎯 **Custom Error Messages** - Override default messages for better UX  
🔄 **Transformations** - Transform values during validation (trim, lowercase, etc.)  
📦 **Zero Dependencies** - Lightweight and fast  
✅ **100% Test Coverage** - Reliable and production-ready  

## Installation

Add to your Gemfile:

```ruby
gem 'validator'
```

Or install directly:

```bash
gem install validator
```

## Quick Start

```ruby
require 'validator'

# Basic validation
validator = Validator.string.min(3).max(50)
result = validator.validate("hello")

result.success?  # => true
result.value     # => "hello"
result.errors    # => []

# With transformations
validator = Validator.string.trim.lowercase.email
result = validator.validate("  USER@EXAMPLE.COM  ")

result.success?  # => true
result.value     # => "user@example.com"
```

## String Validators

### Length Constraints

```ruby
# Minimum length
Validator.string.min(5).validate("hello")

# Maximum length
Validator.string.max(10).validate("hello")

# Exact length
Validator.string.length(5).validate("hello")

# Combine constraints
Validator.string.min(3).max(50).validate("hello")
```

### Format Validators

```ruby
# Email validation
Validator.string.email.validate("user@example.com")

# URL validation
Validator.string.url.validate("https://example.com")

# Custom regex pattern
Validator.string.regex(/\A[A-Z]+\z/).validate("HELLO")

# Alphanumeric only
Validator.string.alphanumeric.validate("abc123")

# Letters only
Validator.string.alpha.validate("hello")

# Numbers only
Validator.string.numeric_string.validate("12345")
```

### Content Validators

```ruby
# Not empty or whitespace
Validator.string.non_empty.validate("hello")

# Starts with prefix
Validator.string.starts_with("hello").validate("hello world")

# Ends with suffix
Validator.string.ends_with(".com").validate("example.com")
```

### Required/Optional

```ruby
# Required field (fails on nil or empty string)
validator = Validator.string.email.required
result = validator.validate(nil)
result.success?  # => false
result.errors    # => ["is required"]

# Optional field (default - allows nil)
validator = Validator.string.email.optional
result = validator.validate(nil)
result.success?  # => true
```

## Integer Validators

### Range Constraints

```ruby
# Minimum value
Validator.integer.min(0).validate(5)

# Maximum value
Validator.integer.max(100).validate(50)

# Between (inclusive)
Validator.integer.between(1, 10).validate(5)

# Comparison
Validator.integer.greater_than(0).validate(5)
Validator.integer.less_than(100).validate(50)
```

### Sign Constraints

```ruby
# Positive (> 0)
Validator.integer.positive.validate(10)

# Negative (< 0)
Validator.integer.negative.validate(-5)

# Non-negative (>= 0)
Validator.integer.non_negative.validate(0)

# Non-positive (<= 0)
Validator.integer.non_positive.validate(-10)
```

### Divisibility

```ruby
# Multiple of
Validator.integer.multiple_of(5).validate(25)

# Even numbers
Validator.integer.even.validate(4)

# Odd numbers
Validator.integer.odd.validate(7)
```

### Coercion

```ruby
# Coerce from string
validator = Validator.integer.coerce.min(100)
result = validator.validate("150")
result.success?  # => true
result.value     # => 150

# Coerce from float (truncates)
result = validator.validate(123.7)
result.value  # => 123
```

### Common Use Cases

```ruby
# Age validation
age_validator = Validator.integer
  .min(0, message: "Age cannot be negative")
  .max(150, message: "Invalid age")
  .required

# Rating system (1-5 stars)
rating_validator = Validator.integer.between(1, 5).required

# Quantity (positive integers only)
quantity_validator = Validator.integer.positive.required

# Page number validation
page_validator = Validator.integer.coerce.positive
  .required

# Discount percentage (0-100)
discount_validator = Validator.integer
  .min(0)
  .max(100)
  .optional
```

## Transformations

Transformations modify the value **before** validation runs. The transformed value is available in `result.value`.

```ruby
# Trim whitespace
validator = Validator.string.trim
result = validator.validate("  hello  ")
result.value  # => "hello"

# Convert to lowercase
validator = Validator.string.lowercase
result = validator.validate("HELLO")
result.value  # => "hello"

# Convert to uppercase
validator = Validator.string.uppercase
result = validator.validate("hello")
result.value  # => "HELLO"

# Chain transformations (applied in order)
validator = Validator.string.trim.lowercase.min(3)
result = validator.validate("  HELLO  ")
result.success?  # => true
result.value     # => "hello"
```

## Custom Error Messages

Override default error messages for better user experience:

```ruby
# Default message
validator = Validator.string.min(5)
result = validator.validate("hi")
result.errors  # => ["must be at least 5 characters"]

# Custom message
validator = Validator.string.min(5, message: "Password too short!")
result = validator.validate("hi")
result.errors  # => ["Password too short!"]

# Works with all validators
Validator.string.email(message: "Invalid email address")
Validator.string.url(message: "Must be a valid URL")
Validator.string.regex(/\A[A-Z]+\z/, message: "Must be uppercase letters only")
```

## Convenience Shortcuts

Pre-configured validator combinations for common use cases:

```ruby
# Non-empty string (required + trim + non_empty)
validator = Validator.string.non_empty_string
result = validator.validate("  hello  ")
result.value  # => "hello"

# Trimmed email (trim + lowercase + email)
validator = Validator.string.trimmed_email
result = validator.validate("  USER@EXAMPLE.COM  ")
result.value  # => "user@example.com"
```

## Advanced Usage

### Complex Validation Pipeline

```ruby
validator = Validator.string
  .trim                          # Remove whitespace
  .lowercase                     # Convert to lowercase
  .min(3)                        # At least 3 chars
  .max(50)                       # At most 50 chars
  .alphanumeric                  # Only letters and numbers
  .starts_with("user")           # Must start with "user"
  .required                      # Cannot be nil

result = validator.validate("  USER12345  ")
result.success?  # => true
result.value     # => "user12345"
```

### Error Handling

```ruby
validator = Validator.string.min(10).max(5).email
result = validator.validate("hi")

if result.failure?
  puts "Validation failed:"
  result.errors.each { |error| puts "  - #{error}" }
  # Output:
  #   - must be at least 10 characters
  #   - must be at most 5 characters
  #   - must be a valid email
  
  # Or get formatted message
  puts result.error_message
  # => "must be at least 10 characters, must be at most 5 characters, must be a valid email"
end
```

## API Reference

### Result Object

```ruby
result = validator.validate(value)

result.success?       # Boolean: true if validation passed
result.failure?       # Boolean: true if validation failed
result.errors         # Array: list of error messages
result.error_message  # String: errors joined by ", "
result.value          # Object: transformed value (or original if no transformations)
```

## Development

After checking out the repo, run:

```bash
bundle install
bundle exec rspec
```

To run tests with coverage:

```bash
bundle exec rspec --format documentation
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git switch -c feat/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Commit your changes (`git commit -am 'feat: Add amazing feature'`)
6. Push to the branch (`git push origin feat/amazing-feature`)
7. Open a Pull Request

Bug reports and pull requests are welcome on GitHub!

## Roadmap

- [ ] Additional validators (integer, float, boolean, array, hash)
- [ ] Async validation support
- [ ] Conditional validations
- [ ] Custom validator registration
- [ ] I18n support for error messages
- [ ] JSON schema export

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Acknowledgments

Inspired by [Zod](https://github.com/colinhacks/zod) (TypeScript) and modern validation libraries.
