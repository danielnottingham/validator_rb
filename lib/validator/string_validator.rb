# frozen_string_literal: true

module Validator
  # Validates string values with various constraints
  #
  # @example Basic usage
  #   validator = Validator.string.min(3).max(10)
  #   result = validator.validate("hello")
  #   result.success? # => true
  #
  # @example With email validation
  #   validator = Validator.string.email.required
  class StringValidator < BaseValidator
    # Sets minimum length constraint
    #
    # @param length [Integer] minimum number of characters
    # @return [self] for method chaining
    #
    # @example
    #   Validator.string.min(5).validate("hello") # passes
    #   Validator.string.min(5).validate("hi")    # fails
    def min(length)
      add_validation do |value|
        value.length >= length || "must be at least #{length} characters"
      end
    end

    # Sets maximum length constraint
    #
    # @param length [Integer] maximum number of characters
    # @return [self] for method chaining
    #
    # @example
    #   Validator.string.max(5).validate("hello") # passes
    #   Validator.string.max(5).validate("hello world") # fails
    def max(length)
      add_validation do |value|
        value.length <= length || "must be at most #{length} characters"
      end
    end

    # Validates that the string is a valid email format
    #
    # Uses a regular expression to check for common email patterns.
    # Note: This is a basic validation and may not cover all edge cases.
    #
    # @return [self] for method chaining
    #
    # @example
    #   Validator.string.email.validate("user@example.com") # passes
    #   Validator.string.email.validate("invalid-email")    # fails
    def email
      add_validation do |value|
        value.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i) || "must be a valid email"
      end
    end

    # Validates that the string is not empty or only whitespace
    #
    # Checks that the string contains at least one non-whitespace character.
    # This is different from `required` which only checks for nil or empty string.
    #
    # @return [self] for method chaining
    #
    # @example
    #   Validator.string.non_empty.validate("hello")  # passes
    #   Validator.string.non_empty.validate("   ")    # fails
    #   Validator.string.non_empty.validate("")       # fails
    def non_empty
      add_validation do |value|
        !value.strip.empty? || "cannot be empty or only whitespace"
      end
    end
  end
end
