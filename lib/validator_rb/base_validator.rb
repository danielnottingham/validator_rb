# frozen_string_literal: true

module ValidatorRb
  require_relative "validation_error"

  # Base class for all validators
  #
  # Provides common validation functionality including:
  # - Support for required/optional fields
  # - Chaining of multiple validations
  # - Aggregation of validation errors
  #
  # This class should not be instantiated directly. Use specific subclasses
  # like StringValidator.
  #
  # @abstract
  class BaseValidator
    # @return [Array<Proc>] list of validation blocks to be executed
    # @return [Array<Proc>] list of transformation blocks to be executed
    # @return [Boolean] indicates whether the field is required
    attr_reader :validations, :transformations, :is_required

    # Initializes a new validator
    #
    # By default, the validator is optional and has no validations or transformations
    def initialize
      @validations = []
      @transformations = []
      @is_required = false
    end

    # Marks this field as required
    #
    # When marked as required, nil or empty string values
    # will result in validation error
    #
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.required.validate("")  # => Result(success: false)
    #   ValidatorRb.string.required.validate(nil) # => Result(success: false)
    def required
      @is_required = true
      self
    end

    # Marks this field as optional (default behavior)
    #
    # Optional fields accept nil or empty string values without error
    #
    # @return [self] for method chaining
    #
    # @example
    #   ValidatorRb.string.optional.validate("")  # => Result(success: true)
    #   ValidatorRb.string.optional.validate(nil) # => Result(success: true)
    def optional
      @is_required = false
      self
    end

    # Executes all configured validations on the provided value
    #
    # Applies transformations first, then runs validations on the transformed value.
    # Returns a Result object containing the validation status, any errors, and the
    # transformed value.
    #
    # @param value [Object] the value to be validated
    # @return [Result] object containing the validation result, errors, and transformed value
    #
    # @example Successful validation
    #   validator = ValidatorRb.string.min(3)
    #   result = validator.validate("hello")
    #   result.success? # => true
    #   result.errors   # => []
    #   result.value    # => "hello"
    #
    # @example Validation with transformations
    #   validator = ValidatorRb.string.trim.lowercase
    #   result = validator.validate("  HELLO  ")
    #   result.value # => "hello"
    #
    # @example Validation with errors
    #   validator = ValidatorRb.string.min(5).email
    #   result = validator.validate("hi")
    #   result.success?      # => false
    #   result.error_message # => "must be at least 5 characters, must be a valid email"
    def validate(value) # rubocop:disable Metrics/MethodLength
      errors = []

      if @is_required && nil_or_empty?(value)
        errors << ValidationError.new("is required", :required)
        return Result.new(false, errors, value)
      end

      return Result.new(true, [], value) if nil_or_empty?(value)

      # Apply transformations
      transformed_value = value
      @transformations.each do |transformation|
        transformed_value = transformation.call(transformed_value)
      end

      # Run validations on transformed value
      @validations.each do |validation|
        result = validation.call(transformed_value)
        errors << result unless result == true
      end

      Result.new(errors.empty?, errors, transformed_value)
    end

    protected

    # Adds a validation block to the list of validations
    #
    # This method is used internally by subclasses to add
    # specific validation rules with optional custom error messages
    #
    # @param message [String, nil] optional custom error message
    # @param code [Symbol, nil] optional error code
    # @param block [Proc] block that receives the value and returns true or error message/object
    # @return [self] for method chaining
    #
    # @example Internal use in subclass
    #   add_validation(code: :too_short) { |value| value.length > 5 || "must be longer" }
    #
    # @example With custom message
    #   add_validation(message: "custom error", code: :custom) { |value| value.length > 5 }
    def add_validation(message: nil, code: :invalid, &block)
      validation = lambda do |value|
        result = block.call(value)

        return true if result == true
        return result if result.is_a?(ValidationError)

        msg = message || (result.is_a?(String) ? result : "invalid value")
        ValidationError.new(msg, code)
      end

      @validations << validation
      self
    end

    # Adds a transformation block to the list of transformations
    #
    # This method is used internally by subclasses to add
    # transformation functions that modify the value before validation
    #
    # @param block [Proc] block that receives the value and returns the transformed value
    # @return [self] for method chaining
    #
    # @example Internal use in subclass
    #   add_transformation { |value| value.strip }
    def add_transformation(&block)
      @transformations << block
      self
    end

    private

    # Checks if a value is nil or empty string
    #
    # @param value [Object] the value to check
    # @return [Boolean] true if value is nil or empty string
    def nil_or_empty?(value)
      value.nil? || value == ""
    end
  end
end
