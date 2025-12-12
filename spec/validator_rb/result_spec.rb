# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::Result do
  describe "#success?" do
    it "returns true when validation passed" do
      result = ValidatorRb::Result.new(true, [])

      expect(result.success?).to be true
    end

    it "returns false when validation failed" do
      result = ValidatorRb::Result.new(false, [ValidatorRb::ValidationError.new("error 1", :code)])

      expect(result.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns true when validation failed" do
      result = ValidatorRb::Result.new(false, [ValidatorRb::ValidationError.new("error 1", :code)])

      expect(result.failure?).to be true
    end

    it "returns false when validation passed" do
      result = ValidatorRb::Result.new(true, [])

      expect(result.failure?).to be false
    end
  end

  describe "#errors" do
    it "returns empty array for successful validation" do
      result = ValidatorRb::Result.new(true, [])

      expect(result.errors).to eq([])
    end

    it "returns array of error objects for failed validation" do
      errors = [
        ValidatorRb::ValidationError.new("too short", :too_short),
        ValidatorRb::ValidationError.new("invalid format", :invalid_format)
      ]
      result = ValidatorRb::Result.new(false, errors)
      expect(result.errors).to eq(errors)
    end
  end

  describe "#error_message" do
    it "returns formatted error message" do
      errors = [
        ValidatorRb::ValidationError.new("too short", :too_short),
        ValidatorRb::ValidationError.new("invalid format", :invalid_format)
      ]
      result = ValidatorRb::Result.new(false, errors)

      expect(result.error_message).to eq("too short, invalid format")
    end

    it "returns empty string when no errors" do
      result = ValidatorRb::Result.new(true, [])

      expect(result.error_message).to eq("")
    end
  end

  describe "#value" do
    it "returns the transformed value when provided" do
      result = ValidatorRb::Result.new(true, [], "hello")

      expect(result.value).to eq("hello")
    end

    it "returns nil when no value is provided" do
      result = ValidatorRb::Result.new(true, [])

      expect(result.value).to be_nil
    end

    it "stores the value even on failed validation" do
      result = ValidatorRb::Result.new(false, [ValidatorRb::ValidationError.new("error", :code)], "invalid")

      expect(result.value).to eq("invalid")
    end
  end
end
