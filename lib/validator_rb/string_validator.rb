# frozen_string_literal: true

module ValidatorRb
  # Validates string values with various constraints
  #
  # Supports transformations (trim, lowercase, uppercase), validations with custom
  # error messages, and convenience shortcuts for common patterns.
  #
  # @example Basic usage
  #   validator = ValidatorRb.string.min(3).max(10)
  #   result = validator.validate("hello")
  #   result.success? # => true
  #
  # @example With transformations
  #   validator = ValidatorRb.string.trim.lowercase
  #   result = validator.validate("  HELLO  ")
  #   result.value # => "hello"
  #
  # @example With custom error messages
  #   validator = ValidatorRb.string.min(3, message: "too short!")
  #   result = validator.validate("hi")
  #   result.error_message # => "too short!"
  class StringValidator < BaseValidator
    # URL validation regex pattern
    URL_REGEX = %r{\Ahttps?://[^\s/$.?#].[^\s]*\z}i

    # ========== LENGTH VALIDATORS ==========

    # Sets minimum length constraint
    #
    # @param length [Integer] minimum number of characters
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.min(5).validate("hello") # passes
    #   ValidatorRb.string.min(5).validate("hi")    # fails
    #
    # @example With custom message
    #   ValidatorRb.string.min(5, message: "too short!").validate("hi")
    def min(length, message: nil)
      add_validation(message: message, code: :too_short) do |value|
        value.length >= length || "must be at least #{length} characters"
      end
    end

    # Sets maximum length constraint
    #
    # @param length [Integer] maximum number of characters
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.max(5).validate("hello") # passes
    #   ValidatorRb.string.max(5).validate("hello world") # fails
    def max(length, message: nil)
      add_validation(message: message, code: :too_long) do |value|
        value.length <= length || "must be at most #{length} characters"
      end
    end

    # Sets exact length constraint
    #
    # @param exact_length [Integer] exact number of characters required
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.length(5).validate("hello") # passes
    #   ValidatorRb.string.length(5).validate("hi")    # fails
    def length(exact_length, message: nil)
      add_validation(message: message, code: :invalid_length) do |value|
        value.length == exact_length || "must be exactly #{exact_length} characters"
      end
    end

    # ========== FORMAT VALIDATORS ==========

    # Validates that the string is a valid email format
    #
    # Uses a regular expression to check for common email patterns.
    # Note: This is a basic validation and may not cover all edge cases.
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.email.validate("user@example.com") # passes
    #   ValidatorRb.string.email.validate("invalid-email")    # fails
    def email(message: nil)
      add_validation(message: message, code: :invalid_email) do |value|
        value.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i) || "must be a valid email"
      end
    end

    # Validates that the string is a valid URL
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.url.validate("https://example.com") # passes
    #   ValidatorRb.string.url.validate("not-a-url")           # fails
    def url(message: nil)
      add_validation(message: message, code: :invalid_url) do |value|
        value.match?(URL_REGEX) || "must be a valid URL"
      end
    end

    # Validates that the string matches a custom regex pattern
    #
    # @param pattern [Regexp] regular expression pattern to match
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.regex(/\A[A-Z]+\z/, message: "must be uppercase letters").validate("ABC")
    def regex(pattern, message: nil)
      add_validation(message: message, code: :invalid_format) do |value|
        value.match?(pattern) || "must match pattern #{pattern.inspect}"
      end
    end

    # Validates that string contains only alphanumeric characters
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.alphanumeric.validate("abc123") # passes
    #   ValidatorRb.string.alphanumeric.validate("abc-123") # fails
    def alphanumeric(message: nil)
      add_validation(message: message, code: :not_alphanumeric) do |value|
        value.match?(/\A[a-z0-9]+\z/i) || "must contain only letters and numbers"
      end
    end

    # Validates that string contains only alphabetic characters
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.alpha.validate("abc") # passes
    #   ValidatorRb.string.alpha.validate("abc123") # fails
    def alpha(message: nil)
      add_validation(message: message, code: :not_alpha) do |value|
        value.match?(/\A[a-z]+\z/i) || "must contain only letters"
      end
    end

    # Validates that string contains only numeric characters
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.numeric_string.validate("123") # passes
    #   ValidatorRb.string.numeric_string.validate("12.3") # fails
    def numeric_string(message: nil)
      add_validation(message: message, code: :not_numeric) do |value|
        value.match?(/\A[0-9]+\z/) || "must contain only numbers"
      end
    end

    # ========== CONTENT VALIDATORS ==========

    # Validates that the string is not empty or only whitespace
    #
    # Checks that the string contains at least one non-whitespace character.
    # This is different from `required` which only checks for nil or empty string.
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.non_empty.validate("hello")  # passes
    #   ValidatorRb.string.non_empty.validate("   ")    # fails
    #   ValidatorRb.string.non_empty.validate("")       # fails
    def non_empty(message: nil)
      add_validation(message: message, code: :empty) do |value|
        !value.strip.empty? || "cannot be empty or only whitespace"
      end
    end

    # Validates that string starts with a specific prefix
    #
    # @param prefix [String] the prefix to check for
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.starts_with("hello").validate("hello world") # passes
    #   ValidatorRb.string.starts_with("hello").validate("goodbye")     # fails
    def starts_with(prefix, message: nil)
      add_validation(message: message, code: :invalid_prefix) do |value|
        value.start_with?(prefix) || "must start with '#{prefix}'"
      end
    end

    # Validates that string ends with a specific suffix
    #
    # @param suffix [String] the suffix to check for
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.ends_with(".com").validate("example.com") # passes
    #   ValidatorRb.string.ends_with(".com").validate("example.org") # fails
    def ends_with(suffix, message: nil)
      add_validation(message: message, code: :invalid_suffix) do |value|
        value.end_with?(suffix) || "must end with '#{suffix}'"
      end
    end

    # ========== TRANSFORMATIONS ==========

    # Trims whitespace from both ends of the string
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.string.trim
    #   result = validator.validate("  hello  ")
    #   result.value # => "hello"
    def trim
      add_transformation(&:strip)
    end

    # Converts string to lowercase
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.string.lowercase
    #   result = validator.validate("HELLO")
    #   result.value # => "hello"
    def lowercase
      add_transformation(&:downcase)
    end

    # Converts string to uppercase
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.string.uppercase
    #   result = validator.validate("hello")
    #   result.value # => "HELLO"
    def uppercase
      add_transformation(&:upcase)
    end

    # ========== CONVENIENCE SHORTCUTS ==========

    # Convenience method combining required, non_empty, and trim
    #
    # Ensures the value is present, not blank, and removes whitespace.
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.string.non_empty_string
    #   result = validator.validate("  hello  ")
    #   result.value # => "hello"
    def non_empty_string
      required.trim.non_empty
    end

    # Convenience method for email validation with trimming and lowercase
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.string.trimmed_email
    #   result = validator.validate("  USER@EXAMPLE.COM  ")
    #   result.value # => "user@example.com"
    def trimmed_email
      trim.lowercase.email
    end
  end
end
