# Contributing to Validator

First off, thank you for considering contributing to Validator! It's people like you that make Validator such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by the [Validator Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible using the bug report template.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please use the feature request template and include:

- A clear and descriptive title
- A detailed description of the proposed feature
- Example code showing how the feature would be used
- Why this enhancement would be useful

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes (`bundle exec rspec`)
4. Make sure your code lints (`bundle exec rubocop`)
5. Update the CHANGELOG.md with your changes
6. Issue that pull request!

## Development Process

### Setting Up Your Development Environment

```bash
# Clone your fork
git clone https://github.com/danielnottingham/validator.git
cd validator

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/validator/string_validator_spec.rb

# Run tests with coverage
bundle exec rspec --format documentation
```

### Code Style

- Follow the existing code style
- Use RuboCop to check your code style
- Write descriptive commit messages
- Add YARD documentation for public methods
- Keep methods focused and testable

### Writing Tests

- Write tests for all new features and bug fixes
- Follow the existing test structure
- Use descriptive test names
- Aim for 100% test coverage

Example test structure:

```ruby
describe "#new_method" do
  it "passes when condition is met" do
    validator = Validator.string.new_method
    result = validator.validate("test")
    
    expect(result.success?).to be true
  end
  
  it "fails when condition is not met" do
    validator = Validator.string.new_method
    result = validator.validate("bad")
    
    expect(result.success?).to be false
    expect(result.errors).to include("expected error message")
  end
  
  it "supports custom error message" do
    validator = Validator.string.new_method(message: "custom")
    result = validator.validate("bad")
    
    expect(result.errors).to include("custom")
  end
end
```

### Documentation

- Update README.md if you're adding new features
- Add YARD documentation to all public methods
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
- Add code examples in documentation

### Commit Messages

- Use the present tense ("feat:Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Example:
```
Add regex pattern validator

- Add regex validation method to StringValidator
- Support custom error messages
- Add comprehensive tests
- Update documentation

Closes #123
```

## Project Structure

```
validator/
├── lib/
│   └── validator/
│       ├── base_validator.rb    # Base validation logic
│       ├── string_validator.rb  # String validators
│       ├── result.rb            # Result object
│       └── version.rb           # Version info
├── spec/
│   └── validator/               # Test files mirror lib/
├── .github/
│   ├── workflows/               # CI/CD workflows
│   └── ISSUE_TEMPLATE/          # Issue templates
└── README.md
```

## Release Process

Maintainers handle releases. The process is:

1. Update version in `lib/validator/version.rb`
2. Update CHANGELOG.md with release date
3. Commit changes
4. Create git tag: `git tag -a v0.2.0 -m "Release v0.2.0"`
5. Push tag: `git push origin v0.2.0`
6. GitHub Actions will automatically publish to RubyGems

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
