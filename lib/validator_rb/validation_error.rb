# frozen_string_literal: true

module ValidatorRb
  # Represents a structured validation error
  #
  # @attr_reader [String] message Human-readable error message
  # @attr_reader [Symbol] code Machine-readable error code
  # @attr_reader [Array<String, Symbol>] path Path to the invalid field
  # @attr_reader [Hash] meta Additional context about the error
  class ValidationError
    attr_reader :message, :code, :path, :meta

    # Initializes a new ValidationError
    #
    # @param message [String] Human-readable error message
    # @param code [Symbol] Machine-readable error code
    # @param path [Array<String, Symbol>] Path to the invalid field (default: [])
    # @param meta [Hash] Additional context (default: {})
    def initialize(message, code, path: [], meta: {})
      @message = message
      @code = code
      @path = path
      @meta = meta
    end

    # Returns a hash representation of the error
    #
    # @return [Hash]
    def to_h
      {
        message: message,
        code: code,
        path: path,
        meta: meta
      }
    end

    # Equality check for testing purposes
    def ==(other)
      other.is_a?(ValidationError) &&
        message == other.message &&
        code == other.code &&
        path == other.path &&
        meta == other.meta
    end
  end
end
