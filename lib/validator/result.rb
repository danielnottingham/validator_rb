# frozen_string_literal: true

module Validator
  # Represents the result of a validation operation
  #
  # Encapsulates the success/failure status and errors found during validation.
  # Provides convenient methods to check the result and access error messages.
  #
  # @example Successful result
  #   result = Result.new(true, [])
  #   result.success? # => true
  #   result.failure? # => false
  #
  # @example Result with errors
  #   result = Result.new(false, ["must be valid", "must be longer"])
  #   result.success?      # => false
  #   result.error_message # => "must be valid, must be longer"
  class Result
    # @return [Array<String>] list of error messages
    attr_reader :errors

    # Initializes a new Result
    #
    # @param success [Boolean] indicates whether the validation was successful
    # @param errors [Array<String>] list of error messages (default: [])
    def initialize(success, errors = [])
      @success = success
      @errors = errors
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
    #   result = Result.new(false, ["error 1", "error 2"])
    #   result.error_message # => "error 1, error 2"
    def error_message
      @errors.join(", ")
    end
  end
end
