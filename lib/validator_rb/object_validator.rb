# frozen_string_literal: true

module ValidatorRb
  # Validates Hash values against a schema of field-level sub-validators.
  #
  # Keys in the schema may be symbols or strings; the input hash is matched
  # against both forms. Sub-validator errors are re-emitted with the schema
  # key prepended to their +path+, producing errors like
  # +path: [:address, :zip]+ for nested objects.
  #
  # @example
  #   validator = ValidatorRb.object(
  #     name: ValidatorRb.string.min(1).required,
  #     email: ValidatorRb.string.email.required
  #   )
  #   result = validator.validate(name: "Alice", email: "alice@example.com")
  #   result.success? # => true
  class ObjectValidator < BaseValidator
    # @param schema [Hash{Symbol,String=>BaseValidator}] field validators
    def initialize(schema = {})
      super()
      @schema = schema
      @strict = false
      @partial = false
      add_validation(code: :not_hash) { |v| v.is_a?(Hash) || "must be a hash" }
      @validations << lambda do |v|
        next true unless v.is_a?(Hash)

        errors = validate_schema(v)
        errors.empty? || errors
      end
    end

    # Flattens nested errors produced by schema validation.
    def validate(value)
      result = super
      result.errors.flatten!
      result
    end

    # Returns a new validator that treats every schema key as optional.
    # Keys that are present in the input are still validated by their
    # sub-validator; keys that are absent are skipped.
    #
    # @return [ObjectValidator]
    def partial
      derive(@schema, partial: true)
    end

    # Returns a new validator whose schema only contains the given keys.
    #
    # @param keys [Array<Symbol,String>]
    # @return [ObjectValidator]
    def pick(keys)
      derive(@schema.select { |k, _| keys.any? { |want| key_match?(k, want) } })
    end

    # Returns a new validator whose schema omits the given keys.
    #
    # @param keys [Array<Symbol,String>]
    # @return [ObjectValidator]
    def omit(keys)
      derive(@schema.reject { |k, _| keys.any? { |want| key_match?(k, want) } })
    end

    # Rejects keys that are not declared in the schema with a +:unknown_key+
    # error. Mutates the receiver for chaining consistency with the other
    # +BaseValidator+ modifiers.
    #
    # @return [self]
    def strict
      @strict = true
      self
    end

    private

    def derive(schema, partial: @partial)
      copy = self.class.new(schema)
      copy.instance_variable_set(:@strict, @strict)
      copy.instance_variable_set(:@partial, partial)
      copy
    end

    def validate_schema(hash)
      errors = []
      @schema.each do |key, sub_validator|
        present, sub_value = fetch_key(hash, key)
        next if @partial && !present

        result = sub_validator.validate(sub_value)
        next if result.success?

        result.errors.each { |e| errors << nested_error(e, key) }
      end
      errors.concat(unknown_key_errors(hash)) if @strict
      errors
    end

    def fetch_key(hash, key)
      return [true, hash[key]] if hash.key?(key)

      alt = key.is_a?(Symbol) ? key.to_s : key.to_sym
      return [true, hash[alt]] if hash.key?(alt)

      [false, nil]
    end

    def nested_error(error, key)
      ValidationError.new(
        error.message,
        error.code,
        path: [key] + error.path,
        meta: error.meta
      )
    end

    def unknown_key_errors(hash)
      hash.keys.reject { |k| @schema.keys.any? { |sk| key_match?(sk, k) } }.map do |k|
        ValidationError.new("unknown key #{k.inspect}", :unknown_key, path: [k])
      end
    end

    def key_match?(lhs, rhs)
      lhs == rhs || lhs.to_s == rhs.to_s
    end
  end
end
