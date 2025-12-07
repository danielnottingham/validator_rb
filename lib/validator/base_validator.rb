# frozen_string_literal: true

module Validator
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
    # @return [Boolean] indicates whether the field is required
    attr_reader :validations, :is_required

    # Initializes a new validator
    #
    # By default, the validator is optional and has no validations
    def initialize
      @validations = []
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
    #   Validator.string.required.validate("")  # => Result(success: false)
    #   Validator.string.required.validate(nil) # => Result(success: false)
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
    #   Validator.string.optional.validate("")  # => Result(success: true)
    #   Validator.string.optional.validate(nil) # => Result(success: true)
    def optional
      @is_required = false
      self
    end

    # Executes all configured validations on the provided value
    #
    # @param value [Object] the value to be validated
    # @return [Result] object containing the validation result and any errors
    #
    # @example Successful validation
    #   validator = Validator.string.min(3)
    #   result = validator.validate("hello")
    #   result.success? # => true
    #   result.errors   # => []
    #
    # @example Validation with errors
    #   validator = Validator.string.min(5).email
    #   result = validator.validate("hi")
    #   result.success?      # => false
    #   result.error_message # => "must be at least 5 characters, must be a valid email"
    def validate(value) # rubocop:disable Metrics/MethodLength
      errors = []

      if @is_required && nil_or_empty?(value)
        errors << "is required"
        return Result.new(false, errors)
      end

      return Result.new(true, []) if nil_or_empty?(value)

      @validations.each do |validation|
        result = validation.call(value)
        errors << result unless result == true
      end

      Result.new(errors.empty?, errors)
    end

    protected

    # Adds a validation block to the list of validations
    #
    # This method is used internally by subclasses to add
    # specific validation rules
    #
    # @param block [Proc] block that receives the value and returns true or error message
    # @return [self] for method chaining
    #
    # @example Internal use in subclass
    #   add_validation { |value| value.length > 5 || "must be longer" }
    def add_validation(&block)
      @validations << block
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
