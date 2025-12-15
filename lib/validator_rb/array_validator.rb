# frozen_string_literal: true

module ValidatorRb
  # Validator for Array types
  class ArrayValidator < BaseValidator
    def initialize
      super
      add_validation(code: :not_array) { |value| value.is_a?(Array) || "must be an array" }
    end

    # Overrides validate to flatten nested errors returned by array validations
    def validate(value)
      result = super
      result.errors.flatten!
      result
    end

    # Validates that the array has at least the specified number of items
    #
    # @param count [Integer] minimum number of items
    # @param message [String, nil] custom error message
    # @return [self]
    def min_items(count, message: nil)
      add_validation(message: message, code: :min_items) do |value|
        value.length >= count || "must have at least #{count} items"
      end
    end

    # Validates that the array has at most the specified number of items
    #
    # @param count [Integer] maximum number of items
    # @param message [String, nil] custom error message
    # @return [self]
    def max_items(count, message: nil)
      add_validation(message: message, code: :max_items) do |value|
        value.length <= count || "must have at most #{count} items"
      end
    end

    # Validates that the array has exactly the specified number of items
    #
    # @param count [Integer] exact number of items
    # @param message [String, nil] custom error message
    # @return [self]
    def length(count, message: nil)
      add_validation(message: message, code: :length) do |value|
        value.length == count || "must have exactly #{count} items"
      end
    end

    # Validates that the array is not empty
    #
    # @param message [String, nil] custom error message
    # @return [self]
    def non_empty(message: nil)
      add_validation(message: message, code: :empty) do |value|
        !value.empty? || "cannot be empty"
      end
    end

    # Validates that the array contains unique elements
    #
    # @param message [String, nil] custom error message
    # @return [self]
    def unique(message: nil)
      add_validation(message: message, code: :unique) do |value|
        value.uniq.length == value.length || "must contain unique elements"
      end
    end

    # Validates that the array contains a specific element
    #
    # @param element [Object] element that must be present
    # @param message [String, nil] custom error message
    # @return [self]
    def contains(element, message: nil)
      add_validation(message: message, code: :missing_element) do |value|
        value.include?(element) || "must contain #{element.inspect}"
      end
    end
    alias includes contains

    # Validates each element of the array using another validator
    #
    # @param validator [BaseValidator] validator to apply to each element
    # @return [self]
    def of(validator)
      validation = lambda do |value|
        errors = validate_elements(value, validator)
        errors.empty? || errors
      end
      @validations << validation
      self
    end

    # Transformation: Removes nil values from the array
    #
    # @return [self]
    def compact
      add_transformation(&:compact)
    end

    # Transformation: Flattens nested arrays
    #
    # @param level [Integer, nil] recursion level (default: nil for all levels)
    # @return [self]
    def flatten(level = nil)
      add_transformation { |value| level ? value.flatten(level) : value.flatten }
    end

    private

    def validate_elements(value, validator)
      errors = []
      value.each_with_index do |item, index|
        result = validator.validate(item)
        next if result.success?

        result.errors.each do |error|
          errors << create_nested_error(error, index)
        end
      end
      errors
    end

    def create_nested_error(error, index)
      ValidationError.new(
        error.message,
        error.code,
        path: [index] + error.path,
        meta: error.meta
      )
    end
  end
end
