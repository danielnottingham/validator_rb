# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::StringValidator do
  describe "existing validators" do
    describe "#min" do
      it "passes when string meets minimum length" do
        validator = ValidatorRb.string.min(3)
        result = validator.validate("hello")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end

      it "fails when string is too short" do
        validator = ValidatorRb.string.min(6)
        result = validator.validate("hello")

        expect(result.success?).to be false
        expect(result.errors).to include("must be at least 6 characters")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.min(6, message: "too short!")
        result = validator.validate("hello")

        expect(result.success?).to be false
        expect(result.errors).to include("too short!")
      end

      it "supports chaining" do
        validator = ValidatorRb.string.min(3).max(10)
        expect(validator).to be_a(ValidatorRb::StringValidator)
      end
    end

    describe "#max" do
      it "passes when string meets maximum length" do
        validator = ValidatorRb.string.max(5)
        result = validator.validate("hello")

        expect(result.success?).to be true
      end

      it "fails when is too long" do
        validator = ValidatorRb.string.max(3)
        result = validator.validate("hello")

        expect(result.success?).to be false
        expect(result.errors).to include("must be at most 3 characters")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.max(3, message: "too long!")
        result = validator.validate("hello")

        expect(result.success?).to be false
        expect(result.errors).to include("too long!")
      end

      it "supports chaining" do
        validator = ValidatorRb.string.max(10).min(3)
        expect(validator).to be_a(ValidatorRb::StringValidator)
      end
    end

    describe "#email" do
      it "passes for valid email" do
        validator = ValidatorRb.string.email
        result = validator.validate("test@example.com")

        expect(result.success?).to be true
      end

      it "fails for invalid email" do
        validator = ValidatorRb.string.email
        result = validator.validate("invalid-email")

        expect(result.success?).to be false
        expect(result.errors).to include("must be a valid email")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.email(message: "invalid email format")
        result = validator.validate("invalid-email")

        expect(result.success?).to be false
        expect(result.errors).to include("invalid email format")
      end

      it "passes for complex valid emails" do
        validator = ValidatorRb.string.email

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
        validator = ValidatorRb.string.non_empty
        result = validator.validate("hello")

        expect(result.success?).to be true
      end

      it "fails for strings with only whitespace" do
        validator = ValidatorRb.string.non_empty
        result = validator.validate("   ")

        expect(result.success?).to be false
        expect(result.errors).to include("cannot be empty or only whitespace")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.non_empty(message: "must not be blank")
        result = validator.validate("   ")

        expect(result.success?).to be false
        expect(result.errors).to include("must not be blank")
      end
    end
  end

  describe "#length" do
    it "passes when string has exact length" do
      validator = ValidatorRb.string.length(5)
      result = validator.validate("hello")

      expect(result.success?).to be true
    end

    it "fails when string is too short" do
      validator = ValidatorRb.string.length(5)
      result = validator.validate("hi")

      expect(result.success?).to be false
      expect(result.errors).to include("must be exactly 5 characters")
    end

    it "fails when string is too long" do
      validator = ValidatorRb.string.length(5)
      result = validator.validate("hello world")

      expect(result.success?).to be false
      expect(result.errors).to include("must be exactly 5 characters")
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.length(5, message: "wrong length")
      result = validator.validate("hi")

      expect(result.success?).to be false
      expect(result.errors).to include("wrong length")
    end
  end

  describe "#url" do
    it "passes for valid URLs" do
      validator = ValidatorRb.string.url

      valid_urls = [
        "https://example.com",
        "http://example.com",
        "https://example.com/path",
        "https://sub.example.com"
      ]

      valid_urls.each do |url|
        result = validator.validate(url)
        expect(result.success?).to be true
      end
    end

    it "fails for invalid URLs" do
      validator = ValidatorRb.string.url

      invalid_urls = [
        "not-a-url",
        "ftp://example.com",
        "example.com",
        "//example.com"
      ]

      invalid_urls.each do |url|
        result = validator.validate(url)
        expect(result.success?).to be false
        expect(result.errors).to include("must be a valid URL")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.url(message: "invalid URL format")
      result = validator.validate("not-a-url")

      expect(result.success?).to be false
      expect(result.errors).to include("invalid URL format")
    end
  end

  describe "#regex" do
    it "passes when string matches pattern" do
      validator = ValidatorRb.string.regex(/\A[A-Z]+\z/)
      result = validator.validate("HELLO")

      expect(result.success?).to be true
    end

    it "fails when string doesn't match pattern" do
      validator = ValidatorRb.string.regex(/\A[A-Z]+\z/)
      result = validator.validate("hello")

      expect(result.success?).to be false
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.regex(/\A[A-Z]+\z/, message: "must be uppercase")
      result = validator.validate("hello")

      expect(result.success?).to be false
      expect(result.errors).to include("must be uppercase")
    end
  end

  describe "#alphanumeric" do
    it "passes for alphanumeric strings" do
      validator = ValidatorRb.string.alphanumeric

      %w[abc123 ABC123 abc 123].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be true
      end
    end

    it "fails for strings with special characters" do
      validator = ValidatorRb.string.alphanumeric

      ["abc-123", "abc_123", "abc 123", "abc@123"].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be false
        expect(result.errors).to include("must contain only letters and numbers")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.alphanumeric(message: "no special chars")
      result = validator.validate("abc-123")

      expect(result.success?).to be false
      expect(result.errors).to include("no special chars")
    end
  end

  describe "#alpha" do
    it "passes for alphabetic strings" do
      validator = ValidatorRb.string.alpha

      %w[abc ABC abcDEF].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be true
      end
    end

    it "fails for strings with numbers or special characters" do
      validator = ValidatorRb.string.alpha

      ["abc123", "abc-def", "abc def", "abc@"].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be false
        expect(result.errors).to include("must contain only letters")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.alpha(message: "letters only")
      result = validator.validate("abc123")

      expect(result.success?).to be false
      expect(result.errors).to include("letters only")
    end
  end

  describe "#numeric_string" do
    it "passes for numeric strings" do
      validator = ValidatorRb.string.numeric_string

      %w[123 0 999].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be true
      end
    end

    it "fails for strings with non-numeric characters" do
      validator = ValidatorRb.string.numeric_string

      ["12.3", "12a", "12 3", "-12"].each do |str|
        result = validator.validate(str)
        expect(result.success?).to be false
        expect(result.errors).to include("must contain only numbers")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.string.numeric_string(message: "numbers only")
      result = validator.validate("12.3")

      expect(result.success?).to be false
      expect(result.errors).to include("numbers only")
    end
  end

  describe "content validators" do
    describe "#starts_with" do
      it "passes when string starts with prefix" do
        validator = ValidatorRb.string.starts_with("hello")
        result = validator.validate("hello world")

        expect(result.success?).to be true
      end

      it "fails when string doesn't start with prefix" do
        validator = ValidatorRb.string.starts_with("hello")
        result = validator.validate("goodbye world")

        expect(result.success?).to be false
        expect(result.errors).to include("must start with 'hello'")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.starts_with("hello", message: "wrong prefix")
        result = validator.validate("goodbye")

        expect(result.success?).to be false
        expect(result.errors).to include("wrong prefix")
      end
    end

    describe "#ends_with" do
      it "passes when string ends with suffix" do
        validator = ValidatorRb.string.ends_with(".com")
        result = validator.validate("example.com")

        expect(result.success?).to be true
      end

      it "fails when string doesn't end with suffix" do
        validator = ValidatorRb.string.ends_with(".com")
        result = validator.validate("example.org")

        expect(result.success?).to be false
        expect(result.errors).to include("must end with '.com'")
      end

      it "supports custom error message" do
        validator = ValidatorRb.string.ends_with(".com", message: "wrong suffix")
        result = validator.validate("example.org")

        expect(result.success?).to be false
        expect(result.errors).to include("wrong suffix")
      end
    end
  end

  describe "transformations" do
    describe "#trim" do
      it "removes leading and trailing whitespace" do
        validator = ValidatorRb.string.trim
        result = validator.validate("  hello  ")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end

      it "works with validations" do
        validator = ValidatorRb.string.trim.min(5)
        result = validator.validate("  hello  ")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end
    end

    describe "#lowercase" do
      it "converts string to lowercase" do
        validator = ValidatorRb.string.lowercase
        result = validator.validate("HELLO")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end

      it "works with validations" do
        validator = ValidatorRb.string.lowercase.starts_with("hello")
        result = validator.validate("HELLO WORLD")

        expect(result.success?).to be true
        expect(result.value).to eq("hello world")
      end
    end

    describe "#uppercase" do
      it "converts string to uppercase" do
        validator = ValidatorRb.string.uppercase
        result = validator.validate("hello")

        expect(result.success?).to be true
        expect(result.value).to eq("HELLO")
      end

      it "works with validations" do
        validator = ValidatorRb.string.uppercase.starts_with("HELLO")
        result = validator.validate("hello world")

        expect(result.success?).to be true
        expect(result.value).to eq("HELLO WORLD")
      end
    end

    describe "chaining transformations" do
      it "applies transformations in order" do
        validator = ValidatorRb.string.trim.lowercase
        result = validator.validate("  HELLO  ")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end

      it "applies all transformations before validations" do
        validator = ValidatorRb.string.trim.lowercase.email
        result = validator.validate("  USER@EXAMPLE.COM  ")

        expect(result.success?).to be true
        expect(result.value).to eq("user@example.com")
      end
    end
  end

  describe "convenience shortcuts" do
    describe "#non_empty_string" do
      it "combines required, trim, and non_empty" do
        validator = ValidatorRb.string.non_empty_string
        result = validator.validate("  hello  ")

        expect(result.success?).to be true
        expect(result.value).to eq("hello")
      end

      it "fails for nil" do
        validator = ValidatorRb.string.non_empty_string
        result = validator.validate(nil)

        expect(result.success?).to be false
        expect(result.errors).to include("is required")
      end

      it "fails for whitespace only" do
        validator = ValidatorRb.string.non_empty_string
        result = validator.validate("   ")

        expect(result.success?).to be false
        expect(result.errors).to include("cannot be empty or only whitespace")
      end
    end

    describe "#trimmed_email" do
      it "combines trim, lowercase, and email" do
        validator = ValidatorRb.string.trimmed_email
        result = validator.validate("  USER@EXAMPLE.COM  ")

        expect(result.success?).to be true
        expect(result.value).to eq("user@example.com")
      end

      it "fails for invalid email" do
        validator = ValidatorRb.string.trimmed_email
        result = validator.validate("  INVALID  ")

        expect(result.success?).to be false
        expect(result.errors).to include("must be a valid email")
      end
    end
  end

  describe "chaining multiple validations" do
    it "passes when all validations pass" do
      validator = ValidatorRb.string.min(5).max(20).email
      result = validator.validate("test@example.com")

      expect(result.success?).to be true
    end

    it "collects all errors when multiple validations fail" do
      validator = ValidatorRb.string.min(10).max(5).email
      result = validator.validate("hi")

      expect(result.success?).to be false
      expect(result.errors.length).to be >= 2
    end
  end

  describe "integration with required" do
    it "fails for nil when required" do
      validator = ValidatorRb.string.min(3).required
      result = validator.validate(nil)

      expect(result.success?).to be false
      expect(result.errors).to include("is required")
    end

    it "passes for nil when optional" do
      validator = ValidatorRb.string.min(3).optional
      result = validator.validate(nil)

      expect(result.success?).to be true
    end

    it "returns nil value for nil input" do
      validator = ValidatorRb.string.optional
      result = validator.validate(nil)

      expect(result.value).to be_nil
    end
  end
end
