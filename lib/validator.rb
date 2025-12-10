# frozen_string_literal: true

require_relative "validator/version"
require_relative "validator/result"
require_relative "validator/base_validator"
require_relative "validator/string_validator"
require_relative "validator/integer_validator"

# Main Validator module
#
# Provides a fluent interface for data validation with support for different types.
# Currently supports string and integer validation with possibility of extension for other types.
#
# @example String validation
#   validator = Validator.string.min(3).max(50).required
#   result = validator.validate("hello")
#   puts result.success? # => true
#   puts result.errors   # => []
#
# @example Integer validation
#   validator = Validator.integer.min(0).max(100).positive
#   result = validator.validate(50)
#   puts result.success? # => true
module Validator
  # Base error for Validator-specific exceptions
  class Error < StandardError; end

  class << self
    # Creates a new StringValidator instance
    #
    # @return [StringValidator] a new string validator instance
    #
    # @example
    #   validator = Validator.string.email.required
    #   result = validator.validate("user@example.com")
    def string
      StringValidator.new
    end

    # Creates a new IntegerValidator instance
    #
    # @return [IntegerValidator] a new integer validator instance
    #
    # @example
    #   validator = Validator.integer.min(0).max(100)
    #   result = validator.validate(50)
    def integer
      IntegerValidator.new
    end
  end
end
