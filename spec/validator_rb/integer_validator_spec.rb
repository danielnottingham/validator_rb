# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::IntegerValidator do
  describe "#min" do
    it "passes when value meets minimum" do
      validator = ValidatorRb.integer.min(5)
      result = validator.validate(10)

      expect(result.success?).to be true
      expect(result.value).to eq(10)
    end

    it "passes when value equals minimum" do
      validator = ValidatorRb.integer.min(5)
      result = validator.validate(5)

      expect(result.success?).to be true
    end

    it "fails when value is less than minimum" do
      validator = ValidatorRb.integer.min(10)
      result = validator.validate(5)

      expect(result.success?).to be false
      expect(result.errors).to include("must be at least 10")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.min(18, message: "Must be an adult")
      result = validator.validate(16)

      expect(result.success?).to be false
      expect(result.errors).to include("Must be an adult")
    end

    it "supports chaining" do
      validator = ValidatorRb.integer.min(0).max(100)
      expect(validator).to be_a(ValidatorRb::IntegerValidator)
    end
  end

  describe "#max" do
    it "passes when value is below maximum" do
      validator = ValidatorRb.integer.max(100)
      result = validator.validate(50)

      expect(result.success?).to be true
    end

    it "passes when value equals maximum" do
      validator = ValidatorRb.integer.max(100)
      result = validator.validate(100)

      expect(result.success?).to be true
    end

    it "fails when value exceeds maximum" do
      validator = ValidatorRb.integer.max(10)
      result = validator.validate(15)

      expect(result.success?).to be false
      expect(result.errors).to include("must be at most 10")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.max(100, message: "Too high!")
      result = validator.validate(150)

      expect(result.success?).to be false
      expect(result.errors).to include("Too high!")
    end
  end

  describe "#between" do
    it "passes when value is within range" do
      validator = ValidatorRb.integer.between(1, 10)
      result = validator.validate(5)

      expect(result.success?).to be true
    end

    it "passes when value equals minimum" do
      validator = ValidatorRb.integer.between(1, 10)
      result = validator.validate(1)

      expect(result.success?).to be true
    end

    it "passes when value equals maximum" do
      validator = ValidatorRb.integer.between(1, 10)
      result = validator.validate(10)

      expect(result.success?).to be true
    end

    it "fails when value is below range" do
      validator = ValidatorRb.integer.between(5, 10)
      result = validator.validate(3)

      expect(result.success?).to be false
      expect(result.errors).to include("must be between 5 and 10")
    end

    it "fails when value is above range" do
      validator = ValidatorRb.integer.between(1, 5)
      result = validator.validate(10)

      expect(result.success?).to be false
      expect(result.errors).to include("must be between 1 and 5")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.between(1, 10, message: "Out of range")
      result = validator.validate(15)

      expect(result.success?).to be false
      expect(result.errors).to include("Out of range")
    end
  end

  describe "#greater_than" do
    it "passes when value is greater" do
      validator = ValidatorRb.integer.greater_than(10)
      result = validator.validate(15)

      expect(result.success?).to be true
    end

    it "fails when value equals threshold" do
      validator = ValidatorRb.integer.greater_than(10)
      result = validator.validate(10)

      expect(result.success?).to be false
      expect(result.errors).to include("must be greater than 10")
    end

    it "fails when value is less" do
      validator = ValidatorRb.integer.greater_than(10)
      result = validator.validate(5)

      expect(result.success?).to be false
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.greater_than(0, message: "Must be positive")
      result = validator.validate(0)

      expect(result.success?).to be false
      expect(result.errors).to include("Must be positive")
    end
  end

  describe "#less_than" do
    it "passes when value is less" do
      validator = ValidatorRb.integer.less_than(100)
      result = validator.validate(50)

      expect(result.success?).to be true
    end

    it "fails when value equals threshold" do
      validator = ValidatorRb.integer.less_than(10)
      result = validator.validate(10)

      expect(result.success?).to be false
      expect(result.errors).to include("must be less than 10")
    end

    it "fails when value is greater" do
      validator = ValidatorRb.integer.less_than(10)
      result = validator.validate(15)

      expect(result.success?).to be false
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.less_than(0, message: "Must be negative")
      result = validator.validate(5)

      expect(result.success?).to be false
      expect(result.errors).to include("Must be negative")
    end
  end

  describe "#positive" do
    it "passes for positive values" do
      validator = ValidatorRb.integer.positive

      [1, 5, 100, 1000].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be true
      end
    end

    it "fails for zero" do
      validator = ValidatorRb.integer.positive
      result = validator.validate(0)

      expect(result.success?).to be false
      expect(result.errors).to include("must be positive")
    end

    it "fails for negative values" do
      validator = ValidatorRb.integer.positive
      result = validator.validate(-5)

      expect(result.success?).to be false
      expect(result.errors).to include("must be positive")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.positive(message: "Only positive numbers allowed")
      result = validator.validate(-1)

      expect(result.success?).to be false
      expect(result.errors).to include("Only positive numbers allowed")
    end
  end

  describe "#negative" do
    it "passes for negative values" do
      validator = ValidatorRb.integer.negative

      [-1, -5, -100].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be true
      end
    end

    it "fails for zero" do
      validator = ValidatorRb.integer.negative
      result = validator.validate(0)

      expect(result.success?).to be false
      expect(result.errors).to include("must be negative")
    end

    it "fails for positive values" do
      validator = ValidatorRb.integer.negative
      result = validator.validate(5)

      expect(result.success?).to be false
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.negative(message: "Only negative numbers")
      result = validator.validate(1)

      expect(result.success?).to be false
      expect(result.errors).to include("Only negative numbers")
    end
  end

  describe "#non_negative" do
    it "passes for zero" do
      validator = ValidatorRb.integer.non_negative
      result = validator.validate(0)

      expect(result.success?).to be true
    end

    it "passes for positive values" do
      validator = ValidatorRb.integer.non_negative
      result = validator.validate(10)

      expect(result.success?).to be true
    end

    it "fails for negative values" do
      validator = ValidatorRb.integer.non_negative
      result = validator.validate(-1)

      expect(result.success?).to be false
      expect(result.errors).to include("must be non-negative")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.non_negative(message: "Cannot be negative")
      result = validator.validate(-5)

      expect(result.success?).to be false
      expect(result.errors).to include("Cannot be negative")
    end
  end

  describe "#non_positive" do
    it "passes for zero" do
      validator = ValidatorRb.integer.non_positive
      result = validator.validate(0)

      expect(result.success?).to be true
    end

    it "passes for negative values" do
      validator = ValidatorRb.integer.non_positive
      result = validator.validate(-10)

      expect(result.success?).to be true
    end

    it "fails for positive values" do
      validator = ValidatorRb.integer.non_positive
      result = validator.validate(1)

      expect(result.success?).to be false
      expect(result.errors).to include("must be non-positive")
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.non_positive(message: "Cannot be positive")
      result = validator.validate(5)

      expect(result.success?).to be false
      expect(result.errors).to include("Cannot be positive")
    end
  end

  describe "#multiple_of" do
    it "passes when value is a multiple" do
      validator = ValidatorRb.integer.multiple_of(5)

      [0, 5, 10, 25, 100].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be true
      end
    end

    it "fails when value is not a multiple" do
      validator = ValidatorRb.integer.multiple_of(5)
      result = validator.validate(23)

      expect(result.success?).to be false
      expect(result.errors).to include("must be a multiple of 5")
    end

    it "works with negative multiples" do
      validator = ValidatorRb.integer.multiple_of(3)
      result = validator.validate(-9)

      expect(result.success?).to be true
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.multiple_of(10, message: "Must be divisible by 10")
      result = validator.validate(15)

      expect(result.success?).to be false
      expect(result.errors).to include("Must be divisible by 10")
    end
  end

  describe "#even" do
    it "passes for even numbers" do
      validator = ValidatorRb.integer.even

      [0, 2, 4, 100, -2, -4].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be true
      end
    end

    it "fails for odd numbers" do
      validator = ValidatorRb.integer.even

      [1, 3, 5, -1, -3].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be false
        expect(result.errors).to include("must be even")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.even(message: "Only even numbers")
      result = validator.validate(3)

      expect(result.success?).to be false
      expect(result.errors).to include("Only even numbers")
    end
  end

  describe "#odd" do
    it "passes for odd numbers" do
      validator = ValidatorRb.integer.odd

      [1, 3, 5, 99, -1, -3].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be true
      end
    end

    it "fails for even numbers" do
      validator = ValidatorRb.integer.odd

      [0, 2, 4, -2, -4].each do |val|
        result = validator.validate(val)
        expect(result.success?).to be false
        expect(result.errors).to include("must be odd")
      end
    end

    it "supports custom error message" do
      validator = ValidatorRb.integer.odd(message: "Only odd numbers")
      result = validator.validate(2)

      expect(result.success?).to be false
      expect(result.errors).to include("Only odd numbers")
    end
  end

  describe "#coerce" do
    it "coerces string to integer" do
      validator = ValidatorRb.integer.coerce
      result = validator.validate("123")

      expect(result.success?).to be true
      expect(result.value).to eq(123)
    end

    it "coerces negative string to integer" do
      validator = ValidatorRb.integer.coerce
      result = validator.validate("-42")

      expect(result.success?).to be true
      expect(result.value).to eq(-42)
    end

    it "coerces float to integer" do
      validator = ValidatorRb.integer.coerce
      result = validator.validate(123.7)

      expect(result.success?).to be true
      expect(result.value).to eq(123)
    end

    it "works with validations after coercion" do
      validator = ValidatorRb.integer.coerce.min(100)
      result = validator.validate("150")

      expect(result.success?).to be true
      expect(result.value).to eq(150)
    end

    it "validation fails if coercion fails" do
      validator = ValidatorRb.integer.coerce.positive
      result = validator.validate("not a number")

      expect(result.success?).to be false
    end
  end

  describe "chaining validations" do
    it "passes when all validations pass" do
      validator = ValidatorRb.integer.min(0).max(100).even
      result = validator.validate(50)

      expect(result.success?).to be true
    end

    it "collects all errors when multiple validations fail" do
      validator = ValidatorRb.integer.min(10).max(100).positive.even
      result = validator.validate(5)

      expect(result.success?).to be false
      expect(result.errors.length).to be >= 1
    end

    it "works with multiple constraints" do
      validator = ValidatorRb.integer
                             .min(1)
                             .max(100)
                             .positive
                             .multiple_of(5)
                             .less_than(50)

      expect(validator.validate(25).success?).to be true
      expect(validator.validate(0).success?).to be false
      expect(validator.validate(150).success?).to be false
      expect(validator.validate(23).success?).to be false
    end
  end

  describe "integration with required" do
    it "fails for nil when required" do
      validator = ValidatorRb.integer.min(0).required
      result = validator.validate(nil)

      expect(result.success?).to be false
      expect(result.errors).to include("is required")
    end

    it "passes for nil when optional" do
      validator = ValidatorRb.integer.min(0).optional
      result = validator.validate(nil)

      expect(result.success?).to be true
    end

    it "returns nil value for nil input" do
      validator = ValidatorRb.integer.optional
      result = validator.validate(nil)

      expect(result.value).to be_nil
    end
  end
end
