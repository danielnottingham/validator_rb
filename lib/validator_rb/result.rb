# frozen_string_literal: true

module ValidatorRb
  require_relative "validation_error"

  # Represents the result of a validation operation
  #
  # Encapsulates the success/failure status, errors found during validation,
  # and the transformed value (if transformations were applied).
  # Provides convenient methods to check the result and access error messages.
  #
  # @example Successful result
  #   result = Result.new(true, [], "hello")
  #   result.success? # => true
  #   result.failure? # => false
  #   result.value    # => "hello"
  #
  # @example Result with errors
  #   result = Result.new(false, ["must be valid", "must be longer"])
  #   result.success?      # => false
  #   result.error_message # => "must be valid, must be longer"
  class Result
    # @return [Array<ValidatorRb::ValidationError>] list of validation errors
    # @return [Object] the transformed/validated value
    attr_reader :errors, :value

    # Initializes a new Result
    #
    # @param success [Boolean] indicates whether the validation was successful
    # @param errors [Array<ValidatorRb::ValidationError>] list of validation errors (default: [])
    # @param value [Object] the transformed/validated value (default: nil)
    def initialize(success, errors = [], value = nil)
      @success = success
      @errors = errors
      @value = value
    end

    # Checks if the validation was successful
    #
    # @return [Boolean] true if there are no validation errors
    def success?
      @success
    end

    # Checks if the validation failed
    #
    # @return [Boolean] true if there are validation errors
    def failure?
      !@success
    end

    # Returns all error messages concatenated
    #
    # @return [String] error messages separated by comma and space
    #
    # @example
    #   result = Result.new(false, [ValidationError.new("error 1", :code1), ValidationError.new("error 2", :code2)])
    #   result.error_message # => "error 1, error 2"
    def error_message
      @errors.map(&:message).join(", ")
    end
  end
end
