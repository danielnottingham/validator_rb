# Validator

Schema validation library with fluent API inspired by Zod.

## Installation

Add to your Gemfile:

```ruby
gem 'validator'
```

Or install directly:

```bash
gem install validator
```

## Usage

### Basic String Validation

```ruby
require 'validator'

# Simple validation
validator = Validator.string.min(3).max(50)
result = validator.validate("hello")

result.success?  # => true
result.errors    # => []

# With required
validator = Validator.string.email.required
result = validator.validate(nil)
result.success?  # => false
result.errors    # => ["is required"]
```

### Chaining Validations

```ruby
validator = Validator.string
  .min(8)
  .max(100)
  .email
  .required

result = validator.validate("user@example.com")
```

## Available Validators

### String

- `.min(length)` - Minimum length
- `.max(length)` - Maximum length
- `.email` - Valid email format
- `.non_empty` - Not empty or whitespace
- `.required` - Field is required
- `.optional` - Field is optional (default)

## Development

After checking out the repo, run:

```bash
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome!

## License

MIT License
