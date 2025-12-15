# ValidatorRb

A fluent, type-safe schema validation library for Ruby inspired by Zod. Build complex validations with chainable methods, custom error messages, and built-in transformations.

[![Ruby](https://img.shields.io/badge/ruby-3.2+-red.svg)](https://www.ruby-lang.org)
[![Tests](https://img.shields.io/badge/tests-166%20passing-success.svg)](spec/)
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
gem 'validator_rb'
```

Or install directly:

```bash
gem install validator_rb
```

## Quick Start

```ruby
require 'validator_rb'

# Basic validation
validator = ValidatorRb.string.min(3).max(50)
result = validator.validate("hello")

result.success?  # => true
result.value     # => "hello"
result.success?  # => true
result.value     # => "hello"
result.errors    # => [] # Array of ValidatorRb::ValidationError objects

# With transformations
validator = ValidatorRb.string.trim.lowercase.email
result = validator.validate("  USER@EXAMPLE.COM  ")

result.success?  # => true
result.value     # => "user@example.com"
```

## String Validators

### Length Constraints

```ruby
# Minimum length
ValidatorRb.string.min(5).validate("hello")

# Maximum length
ValidatorRb.string.max(10).validate("hello")

# Exact length
ValidatorRb.string.length(5).validate("hello")

# Combine constraints
ValidatorRb.string.min(3).max(50).validate("hello")
```

### Format Validators

```ruby
# Email validation
ValidatorRb.string.email.validate("user@example.com")

# URL validation
ValidatorRb.string.url.validate("https://example.com")

# Custom regex pattern
ValidatorRb.string.regex(/\A[A-Z]+\z/).validate("HELLO")

# Alphanumeric only
ValidatorRb.string.alphanumeric.validate("abc123")

# Letters only
ValidatorRb.string.alpha.validate("hello")

# Numbers only
ValidatorRb.string.numeric_string.validate("12345")
```

### Content Validators

```ruby
# Not empty or whitespace
ValidatorRb.string.non_empty.validate("hello")

# Starts with prefix
ValidatorRb.string.starts_with("hello").validate("hello world")

# Ends with suffix
ValidatorRb.string.ends_with(".com").validate("example.com")
```

### Required/Optional

```ruby
# Required field (fails on nil or empty string)
validator = ValidatorRb.string.email.required
result = validator.validate(nil)
result.success?  # => false
result.success?  # => false
result.errors.first.message # => "is required"
result.errors.first.code    # => :required

# Optional field (default - allows nil)
validator = ValidatorRb.string.email.optional
result = validator.validate(nil)
result.success?  # => true
```

## Integer Validators

### Range Constraints

```ruby
# Minimum value
ValidatorRb.integer.min(0).validate(5)

# Maximum value
ValidatorRb.integer.max(100).validate(50)

# Between (inclusive)
ValidatorRb.integer.between(1, 10).validate(5)

# Comparison
ValidatorRb.integer.greater_than(0).validate(5)
ValidatorRb.integer.less_than(100).validate(50)
```

### Sign Constraints

```ruby
# Positive (> 0)
ValidatorRb.integer.positive.validate(10)

# Negative (< 0)
ValidatorRb.integer.negative.validate(-5)

# Non-negative (>= 0)
ValidatorRb.integer.non_negative.validate(0)

# Non-positive (<= 0)
ValidatorRb.integer.non_positive.validate(-10)
```

### Divisibility

```ruby
# Multiple of
ValidatorRb.integer.multiple_of(5).validate(25)

# Even numbers
ValidatorRb.integer.even.validate(4)

# Odd numbers
ValidatorRb.integer.odd.validate(7)
```

### Coercion

```ruby
# Coerce from string
validator = ValidatorRb.integer.coerce.min(100)
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
age_validator = ValidatorRb.integer
  .min(0, message: "Age cannot be negative")
  .max(150, message: "Invalid age")
  .required

# Rating system (1-5 stars)
rating_validator = ValidatorRb.integer.between(1, 5).required

# Quantity (positive integers only)
quantity_validator = ValidatorRb.integer.positive.required

# Page number validation
page_validator = ValidatorRb.integer.coerce.positive
  .required

# Discount percentage (0-100)
discount_validator = ValidatorRb.integer
  .min(0)
  .max(100)
  .optional

## Array Validators

### Size Constraints

```ruby
# Minimum items
ValidatorRb.array.min_items(1).validate([1, 2, 3])

# Maximum items
ValidatorRb.array.max_items(5).validate([1, 2, 3])

# Exact length
ValidatorRb.array.length(3).validate([1, 2, 3])

# Not empty
ValidatorRb.array.non_empty.validate([1])
```

### Content Validation

```ruby
# Unique elements
ValidatorRb.array.unique.validate([1, 2, 3])

# Contains specific element
ValidatorRb.array.contains("admin").validate(["user", "admin"])
ValidatorRb.array.includes(1).validate([1, 2, 3])
```

### Element Validation

Validate each element in the array using another validator:

```ruby
# Array of strings
ValidatorRb.array.of(ValidatorRb.string).validate(["a", "b"])

# Array of positive integers
ValidatorRb.array.of(ValidatorRb.integer.positive).validate([1, 2, 3])

# Nested arrays
inner = ValidatorRb.array.of(ValidatorRb.integer)
ValidatorRb.array.of(inner).validate([[1, 2], [3, 4]])
```

### Transformations

```ruby
# Compact (remove nil)
validator = ValidatorRb.array.compact
result = validator.validate([1, nil, 2])
result.value # => [1, 2]

# Flatten
validator = ValidatorRb.array.flatten
result = validator.validate([[1, 2], [3, 4]])
result.value # => [1, 2, 3, 4]
```
```

## Transformations

Transformations modify the value **before** validation runs. The transformed value is available in `result.value`.

```ruby
# Trim whitespace
validator = ValidatorRb.string.trim
result = validator.validate("  hello  ")
result.value  # => "hello"

# Convert to lowercase
validator = ValidatorRb.string.lowercase
result = validator.validate("HELLO")
result.value  # => "hello"

# Convert to uppercase
validator = ValidatorRb.string.uppercase
result = validator.validate("hello")
result.value  # => "HELLO"

# Chain transformations (applied in order)
validator = ValidatorRb.string.trim.lowercase.min(3)
result = validator.validate("  HELLO  ")
result.success?  # => true
result.value     # => "hello"
```

## Custom Error Messages

Override default error messages for better user experience:

```ruby
# Default message
validator = ValidatorRb.string.min(5)
result = validator.validate("hi")
result.errors.first.message # => "must be at least 5 characters"
result.errors.first.code    # => :too_short

# Custom message
validator = ValidatorRb.string.min(5, message: "Password too short!")
result = validator.validate("hi")
result.errors.first.message # => "Password too short!"
result.errors.first.code    # => :too_short

# Works with all validators
ValidatorRb.string.email(message: "Invalid email address")
ValidatorRb.string.url(message: "Must be a valid URL")
ValidatorRb.string.regex(/\A[A-Z]+\z/, message: "Must be uppercase letters only")
```

## Convenience Shortcuts

Pre-configured validator combinations for common use cases:

```ruby
# Non-empty string (required + trim + non_empty)
validator = ValidatorRb.string.non_empty_string
result = validator.validate("  hello  ")
result.value  # => "hello"

# Trimmed email (trim + lowercase + email)
validator = ValidatorRb.string.trimmed_email
result = validator.validate("  USER@EXAMPLE.COM  ")
result.value  # => "user@example.com"
```

## Advanced Usage

### Complex Validation Pipeline

```ruby
validator = ValidatorRb.string
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
validator = ValidatorRb.string.min(10).max(5).email
result = validator.validate("hi")

if result.failure?
  puts "Validation failed:"
  result.errors.each do |error|
    puts "  - Message: #{error.message}"
    puts "  - Code:    #{error.code}"
    puts "  - Path:    #{error.path}"
  end
  # Output:
  #   - Message: must be at least 10 characters
  #   - Code:    :too_short
  #   - Path:    []
  #   ...
  
  # Or get formatted message (backward compatibility)
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
result.errors         # Array<ValidationError>: list of error objects
result.error_message  # String: errors joined by ", "
result.value          # Object: transformed value (or original if no transformations)

### ValidationError Object

```ruby
error = result.errors.first

error.message # String: Human-readable error message
error.code    # Symbol: Machine-readable error code (e.g., :too_short, :invalid_email)
error.path    # Array: Path to the invalid field (default: [])
error.meta    # Hash: Additional context (default: {})
error.to_h    # Hash: Serialized error representation
```
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

- [ ] Additional validators (float, boolean, array, hash)
- [ ] Async validation support
- [ ] Conditional validations
- [ ] Custom validator registration
- [ ] I18n support for error messages
- [ ] JSON schema export

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Acknowledgments

Inspired by [Zod](https://github.com/colinhacks/zod) (TypeScript) and modern validation libraries.
