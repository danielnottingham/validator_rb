# frozen_string_literal: true

require "spec_helper"

RSpec.describe Validator::BaseValidator do
  describe "#required" do
    it "marks validator as required" do
      validator = Validator::BaseValidator.new
      validator.required
      expect(validator.is_required).to be true
    end

    it "returns self for chaining" do
      validator = Validator::BaseValidator.new
      expect(validator.required).to eq(validator)
    end
  end

  describe "#optional" do
    it "marks validator as optional" do
      validator = Validator::BaseValidator.new
      validator.required.optional
      expect(validator.is_required).to be false
    end

    it "returns self for chaining" do
      validator = Validator::BaseValidator.new
      expect(validator.optional).to eq(validator)
    end
  end

  describe "#validate" do
    context "when required" do
      it "fails validation for nil value" do
        validator = Validator::BaseValidator.new.required
        result = validator.validate(nil)

        expect(result.success?).to be false
        expect(result.errors).to include("is required")
      end

      it "fails validation for empty string" do
        validator = Validator::BaseValidator.new.required
        result = validator.validate("")

        expect(result.success?).to be false
        expect(result.errors).to include("is required")
      end
    end

    context "when optional" do
      it "passes validation for nil value" do
        validator = Validator::BaseValidator.new.optional
        result = validator.validate(nil)

        expect(result.success?).to be true
        expect(result.errors).to be_empty
      end

      it "passes validation for empty string" do
        validator = Validator::BaseValidator.new.optional
        result = validator.validate("")

        expect(result.success?).to be true
        expect(result.errors).to be_empty
      end
    end
  end
end
