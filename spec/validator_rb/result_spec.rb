# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::Result do
  describe "#success?" do
    it "returns true when validation passed" do
      result = ValidatorRb::Result.new(true, [])
      expect(result.success?).to be true
    end

    it "returns false when validation failed" do
      result = ValidatorRb::Result.new(false, ["error 1"])
      expect(result.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns true when validation failed" do
      result = ValidatorRb::Result.new(false, ["error 1"])
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

    it "returns array of error messages for failed validation" do
      errors = ["too short", "invalid format"]
      result = ValidatorRb::Result.new(false, errors)
      expect(result.errors).to eq(errors)
    end
  end

  describe "#error_message" do
    it "returns formatted error message" do
      result = ValidatorRb::Result.new(false, ["too short", "invalid format"])
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
      result = ValidatorRb::Result.new(false, ["error"], "invalid")
      expect(result.value).to eq("invalid")
    end
  end
end
