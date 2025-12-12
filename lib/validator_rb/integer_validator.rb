# frozen_string_literal: true

module ValidatorRb
  require_relative "validation_error"

  # Validates integer values with various constraints
  #
  # Supports range validation, sign constraints, divisibility checks,
  # and optional coercion from strings.
  #
  # @example Basic usage
  #   validator = ValidatorRb.integer.min(0).max(100)
  #   result = validator.validate(50)
  #   result.success? # => true
  #
  # @example With sign constraints
  #   validator = ValidatorRb.integer.positive
  #   result = validator.validate(10)
  #   result.success? # => true
  #
  # @example With custom error messages
  #   validator = ValidatorRb.integer.min(18, message: "Must be an adult")
  #   result = validator.validate(16)
  #   result.errors # => ["Must be an adult"]
  class IntegerValidator < BaseValidator
    def initialize
      super
      # Add base type validation - must be an Integer
      add_validation(code: :not_integer) do |value|
        value.is_a?(Integer) || "must be an integer"
      end
    end
    # ========== RANGE VALIDATORS ==========

    # Sets minimum value constraint
    #
    # @param value [Integer] minimum value (inclusive)
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.min(0).validate(5)   # passes
    #   ValidatorRb.integer.min(10).validate(5)  # fails
    def min(value, message: nil)
      add_validation(message: message, code: :too_small) do |val|
        val >= value || "must be at least #{value}"
      end
    end

    # Sets maximum value constraint
    #
    # @param value [Integer] maximum value (inclusive)
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.max(100).validate(50)  # passes
    #   ValidatorRb.integer.max(10).validate(50)   # fails
    def max(value, message: nil)
      add_validation(message: message, code: :too_large) do |val|
        val <= value || "must be at most #{value}"
      end
    end

    # Sets range constraint (inclusive)
    #
    # @param min_value [Integer] minimum value (inclusive)
    # @param max_value [Integer] maximum value (inclusive)
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.between(1, 10).validate(5)  # passes
    #   ValidatorRb.integer.between(1, 10).validate(15) # fails
    def between(min_value, max_value, message: nil)
      add_validation(message: message, code: :not_in_range) do |val|
        (val >= min_value && val <= max_value) || "must be between #{min_value} and #{max_value}"
      end
    end

    # ========== COMPARISON VALIDATORS ==========

    # Value must be greater than specified value (exclusive)
    #
    # @param value [Integer] value to compare against
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.greater_than(10).validate(15) # passes
    #   ValidatorRb.integer.greater_than(10).validate(10) # fails
    def greater_than(value, message: nil)
      add_validation(message: message, code: :not_greater_than) do |val|
        val > value || "must be greater than #{value}"
      end
    end

    # Value must be less than specified value (exclusive)
    #
    # @param value [Integer] value to compare against
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.less_than(100).validate(50) # passes
    #   ValidatorRb.integer.less_than(10).validate(10)  # fails
    def less_than(value, message: nil)
      add_validation(message: message, code: :not_less_than) do |val|
        val < value || "must be less than #{value}"
      end
    end

    # ========== SIGN VALIDATORS ==========

    # Value must be positive (> 0)
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.positive.validate(10) # passes
    #   ValidatorRb.integer.positive.validate(0)  # fails
    #   ValidatorRb.integer.positive.validate(-5) # fails
    def positive(message: nil)
      add_validation(message: message, code: :not_positive) do |val|
        next "must be an integer" unless val.is_a?(Integer)

        val.positive? || "must be positive"
      end
    end

    # Value must be negative (< 0)
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.negative.validate(-5) # passes
    #   ValidatorRb.integer.negative.validate(0)  # fails
    #   ValidatorRb.integer.negative.validate(5)  # fails
    def negative(message: nil)
      add_validation(message: message, code: :not_negative) do |val|
        next "must be an integer" unless val.is_a?(Integer)

        val.negative? || "must be negative"
      end
    end

    # Value must be non-negative (>= 0)
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.non_negative.validate(0)  # passes
    #   ValidatorRb.integer.non_negative.validate(5)  # passes
    #   ValidatorRb.integer.non_negative.validate(-1) # fails
    def non_negative(message: nil)
      add_validation(message: message, code: :negative) do |val|
        val >= 0 || "must be non-negative"
      end
    end

    # Value must be non-positive (<= 0)
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.non_positive.validate(0)  # passes
    #   ValidatorRb.integer.non_positive.validate(-5) # passes
    #   ValidatorRb.integer.non_positive.validate(1)  # fails
    def non_positive(message: nil)
      add_validation(message: message, code: :positive) do |val|
        val <= 0 || "must be non-positive"
      end
    end

    # ========== DIVISIBILITY VALIDATORS ==========

    # Value must be a multiple of specified number
    #
    # @param divisor [Integer] the divisor
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.multiple_of(5).validate(25) # passes
    #   ValidatorRb.integer.multiple_of(5).validate(23) # fails
    def multiple_of(divisor, message: nil)
      add_validation(message: message, code: :not_multiple_of) do |val|
        (val % divisor).zero? || "must be a multiple of #{divisor}"
      end
    end

    # Value must be even
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.even.validate(4) # passes
    #   ValidatorRb.integer.even.validate(5) # fails
    def even(message: nil)
      add_validation(message: message, code: :not_even) do |val|
        val.even? || "must be even"
      end
    end

    # Value must be odd
    #
    # @param message [String, nil] custom error message
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.integer.odd.validate(5) # passes
    #   ValidatorRb.integer.odd.validate(4) # fails
    def odd(message: nil)
      add_validation(message: message, code: :not_odd) do |val|
        val.odd? || "must be odd"
      end
    end

    # ========== TRANSFORMATION ==========

    # Coerce value to integer from string or float
    #
    # @return [self] for method chaining
    #
    # @example
    #   validator = ValidatorRb.integer.coerce
    #   result = validator.validate("123")
    #   result.value # => 123
    #
    # @example With float
    #   validator = ValidatorRb.integer.coerce
    #   result = validator.validate(123.7)
    #   result.value # => 123
    def coerce
      add_transformation do |value|
        Integer(value)
      rescue ArgumentError, TypeError
        value
      end
    end
  end
end
