# frozen_string_literal: true

require "spec_helper"

RSpec.describe Validator::Result do
  describe "#success?" do
    it "returns true when validation passed" do
      result = Validator::Result.new(true, [])
      expect(result.success?).to be true
    end

    it "returns false when validation failed" do
      result = Validator::Result.new(false, ["error 1"])
      expect(result.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns true when validation failed" do
      result = Validator::Result.new(false, ["error 1"])
      expect(result.failure?).to be true
    end

    it "returns false when validation passed" do
      result = Validator::Result.new(true, [])
      expect(result.failure?).to be false
    end
  end

  describe "#errors" do
    it "returns empty array for successful validation" do
      result = Validator::Result.new(true, [])
      expect(result.errors).to eq([])
    end

    it "returns array of error messages for failed validation" do
      errors = ["too short", "invalid format"]
      result = Validator::Result.new(false, errors)
      expect(result.errors).to eq(errors)
    end
  end

  describe "#error_message" do
    it "returns formatted error message" do
      result = Validator::Result.new(false, ["too short", "invalid format"])
      expect(result.error_message).to eq("too short, invalid format")
    end

    it "returns empty string when no errors" do
      result = Validator::Result.new(true, [])
      expect(result.error_message).to eq("")
    end
  end
end
