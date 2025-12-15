# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::ArrayValidator do
  describe "basic validation" do
    it "passes for an array" do
      validator = ValidatorRb.array
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be true
      expect(result.value).to eq([1, 2, 3])
    end

    it "fails for non-array" do
      validator = ValidatorRb.array
      result = validator.validate("not an array")

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must be an array", :not_array))
    end
  end

  describe "#min_items" do
    it "passes when array has enough items" do
      validator = ValidatorRb.array.min_items(2)
      result = validator.validate([1, 2])

      expect(result.success?).to be true
    end

    it "fails when array has too few items" do
      validator = ValidatorRb.array.min_items(3)
      result = validator.validate([1, 2])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must have at least 3 items", :min_items))
    end

    it "supports custom error message" do
      validator = ValidatorRb.array.min_items(3, message: "Too few items")
      result = validator.validate([1])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("Too few items", :min_items))
    end
  end

  describe "#max_items" do
    it "passes when array has few enough items" do
      validator = ValidatorRb.array.max_items(3)
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be true
    end

    it "fails when array has too many items" do
      validator = ValidatorRb.array.max_items(2)
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must have at most 2 items", :max_items))
    end
  end

  describe "#length" do
    it "passes when array has exact number of items" do
      validator = ValidatorRb.array.length(3)
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be true
    end

    it "fails when array has wrong number of items" do
      validator = ValidatorRb.array.length(3)
      result = validator.validate([1, 2])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must have exactly 3 items", :length))
    end
  end

  describe "#non_empty" do
    it "passes for non-empty array" do
      validator = ValidatorRb.array.non_empty
      result = validator.validate([1])

      expect(result.success?).to be true
    end

    it "fails for empty array" do
      validator = ValidatorRb.array.non_empty
      result = validator.validate([])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("cannot be empty", :empty))
    end
  end

  describe "#unique" do
    it "passes for array with unique elements" do
      validator = ValidatorRb.array.unique
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be true
    end

    it "fails for array with duplicate elements" do
      validator = ValidatorRb.array.unique
      result = validator.validate([1, 2, 2])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must contain unique elements", :unique))
    end
  end

  describe "#contains" do
    it "passes when element is present" do
      validator = ValidatorRb.array.contains("admin")
      result = validator.validate(%w[user admin])

      expect(result.success?).to be true
    end

    it "fails when element is missing" do
      validator = ValidatorRb.array.contains("admin")
      result = validator.validate(%w[user guest])

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new('must contain "admin"', :missing_element))
    end

    it "is aliased as includes" do
      validator = ValidatorRb.array.includes(1)
      result = validator.validate([2, 3])

      expect(result.success?).to be false
      expect(result.errors.first.code).to eq(:missing_element)
    end
  end

  describe "#of" do
    it "validates each element" do
      validator = ValidatorRb.array.of(ValidatorRb.integer.positive)
      result = validator.validate([1, 2, 3])

      expect(result.success?).to be true
    end

    it "fails when an element is invalid" do
      validator = ValidatorRb.array.of(ValidatorRb.integer.positive)
      result = validator.validate([1, -2, 3])

      expect(result.success?).to be false
      expect(result.errors.length).to eq(1)

      error = result.errors.first
      expect(error.code).to eq(:not_positive)
      expect(error.path).to eq([1])
    end

    it "collects multiple errors" do
      validator = ValidatorRb.array.of(ValidatorRb.integer.positive)
      result = validator.validate([-1, -2])

      expect(result.success?).to be false
      expect(result.errors.length).to eq(2)

      expect(result.errors[0].path).to eq([0])
      expect(result.errors[1].path).to eq([1])
    end

    it "supports nested arrays" do
      # Array of arrays of positive integers
      inner_validator = ValidatorRb.array.of(ValidatorRb.integer.positive)
      validator = ValidatorRb.array.of(inner_validator)

      result = validator.validate([[1, 2], [3, -4]])

      expect(result.success?).to be false
      error = result.errors.first
      expect(error.path).to eq([1, 1]) # Second array, second item
      expect(error.code).to eq(:not_positive)
    end
  end

  describe "transformations" do
    describe "#compact" do
      it "removes nil values" do
        validator = ValidatorRb.array.compact
        result = validator.validate([1, nil, 2])

        expect(result.success?).to be true
        expect(result.value).to eq([1, 2])
      end
    end

    describe "#flatten" do
      it "flattens nested arrays" do
        validator = ValidatorRb.array.flatten
        result = validator.validate([[1, 2], [3, 4]])

        expect(result.success?).to be true
        expect(result.value).to eq([1, 2, 3, 4])
      end

      it "flattens to specified level" do
        validator = ValidatorRb.array.flatten(1)
        result = validator.validate([[1, [2]], [3]])

        expect(result.success?).to be true
        expect(result.value).to eq([1, [2], 3])
      end
    end
  end
end
