# frozen_string_literal: true

require "spec_helper"

RSpec.describe Validator::StringValidator do
  describe "#min" do
    it "passes when string meets minimum length" do
      validator = Validator.string.min(3)

      result = validator.validate("hello")

      expect(result.success?).to be true
    end

    it "fails when string is too short" do
      validator = Validator.string.min(6)

      result = validator.validate("hello")

      expect(result.success?).to be false
      expect(result.errors).to include("must be at least 6 characters")
    end

    it "supports chaining" do
      validator = Validator.string.min(3).max(10)

      expect(validator).to be_a(Validator::StringValidator)
    end
  end

  describe "#max" do
    it "passes when string meets maximum length" do
      validator = Validator.string.max(5)

      result = validator.validate("hello")

      expect(result.success?).to be true
    end

    it "fails when is too long" do
      validator = Validator.string.max(3)

      result = validator.validate("hello")

      expect(result.success?).to be false
      expect(result.errors).to include("must be at most 3 characters")
    end

    it "supports chaining" do
      validator = Validator.string.max(10).min(3)

      expect(validator).to be_a(Validator::StringValidator)
    end
  end

  describe "#email" do
    it "passes for valid email" do
      validator = Validator.string.email
      result = validator.validate("test@example.com")

      expect(result.success?).to be true
    end

    it "fails for invalid email" do
      validator = Validator.string.email
      result = validator.validate("invalid-email")

      expect(result.success?).to be false
      expect(result.errors).to include("must be a valid email")
    end

    it "passes for complex valid emails" do
      validator = Validator.string.email

      valid_emails = [
        "user@example.com",
        "user.name@example.com",
        "user+tag@example.co.uk"
      ]

      valid_emails.each do |email|
        result = validator.validate(email)
        expect(result.success?).to be true
      end
    end
  end

  describe "#non_empty" do
    it "passes for non-empty strings" do
      validator = Validator.string.non_empty
      result = validator.validate("hello")

      expect(result.success?).to be true
    end

    it "fails for strings with only whitespace" do
      validator = Validator.string.non_empty
      result = validator.validate("   ")

      expect(result.success?).to be false
      expect(result.errors).to include("cannot be empty or only whitespace")
    end
  end

  describe "chaining multiple validations" do
    it "passes when all validations pass" do
      validator = Validator.string.min(5).max(20).email
      result = validator.validate("test@example.com")

      expect(result.success?).to be true
    end

    it "collects all errors when multiple validations fail" do
      validator = Validator.string.min(10).max(5).email
      result = validator.validate("hi")

      expect(result.success?).to be false
      expect(result.errors.length).to be >= 2
    end
  end

  describe "integration with required" do
    it "fails for nil when required" do
      validator = Validator.string.min(3).required
      result = validator.validate(nil)

      expect(result.success?).to be false
      expect(result.errors).to include("is required")
    end

    it "passes for nil when optional" do
      validator = Validator.string.min(3).optional
      result = validator.validate(nil)

      expect(result.success?).to be true
    end
  end
end
