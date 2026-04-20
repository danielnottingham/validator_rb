# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::ObjectValidator do
  describe "basic validation" do
    it "passes for a hash" do
      validator = ValidatorRb.object
      result = validator.validate({ name: "John" })

      expect(result.success?).to be true
      expect(result.value).to eq({ name: "John" })
    end

    it "fails for a non-hash value" do
      validator = ValidatorRb.object
      result = validator.validate("not a hash")

      expect(result.success?).to be false
      expect(result.errors).to include(ValidatorRb::ValidationError.new("must be a hash", :not_hash))
    end

    it "does not run schema validations when value is not a hash" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required)
      result = validator.validate("not a hash")

      expect(result.errors.map(&:code)).to eq([:not_hash])
    end
  end

  describe "schema validation" do
    it "passes when every field is valid" do
      validator = ValidatorRb.object(
        name: ValidatorRb.string.min(1).required,
        age: ValidatorRb.integer.min(0).optional
      )
      result = validator.validate({ name: "Alice", age: 30 })

      expect(result.success?).to be true
    end

    it "collects errors from every invalid field with a key path" do
      validator = ValidatorRb.object(
        name: ValidatorRb.string.min(3).required,
        email: ValidatorRb.string.email.required
      )
      result = validator.validate({ name: "Al", email: "not-an-email" })

      expect(result.success?).to be false
      expect(result.errors.length).to eq(2)

      by_path = result.errors.each_with_object({}) { |e, h| h[e.path] = e.code }
      expect(by_path).to eq(
        [:name] => :too_short,
        [:email] => :invalid_email
      )
    end

    it "reports :required for missing keys when the sub-validator is required" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required)
      result = validator.validate({})

      expect(result.success?).to be false
      error = result.errors.first
      expect(error.code).to eq(:required)
      expect(error.path).to eq([:name])
    end

    it "treats missing keys as nil for optional sub-validators" do
      validator = ValidatorRb.object(nickname: ValidatorRb.string.optional)
      result = validator.validate({})

      expect(result.success?).to be true
    end

    it "accepts string keys in the input when the schema uses symbol keys" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required)
      result = validator.validate({ "name" => "Alice" })

      expect(result.success?).to be true
    end

    it "accepts symbol keys in the input when the schema uses string keys" do
      validator = ValidatorRb.object("name" => ValidatorRb.string.required)
      result = validator.validate({ name: "Alice" })

      expect(result.success?).to be true
    end
  end

  describe "nested objects" do
    let(:validator) do
      ValidatorRb.object(
        name: ValidatorRb.string.required,
        address: ValidatorRb.object(
          street: ValidatorRb.string.required,
          zip: ValidatorRb.string.regex(/\A\d{5}\z/).optional
        )
      )
    end

    it "passes when nested schemas are satisfied" do
      result = validator.validate(
        name: "Alice",
        address: { street: "Main", zip: "12345" }
      )

      expect(result.success?).to be true
    end

    it "builds a path across nesting levels" do
      result = validator.validate(
        name: "Alice",
        address: { street: "Main", zip: "abc" }
      )

      expect(result.success?).to be false
      error = result.errors.first
      expect(error.path).to eq(%i[address zip])
      expect(error.code).to eq(:invalid_format)
    end
  end

  describe "#strict" do
    it "rejects keys that are not in the schema" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required).strict
      result = validator.validate({ name: "Alice", extra: 1 })

      expect(result.success?).to be false
      error = result.errors.find { |e| e.code == :unknown_key }
      expect(error).not_to be_nil
      expect(error.path).to eq([:extra])
    end

    it "matches keys regardless of string/symbol form" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required).strict
      result = validator.validate({ "name" => "Alice" })

      expect(result.success?).to be true
    end

    it "passes when no extra keys are present" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required).strict
      result = validator.validate({ name: "Alice" })

      expect(result.success?).to be true
    end
  end

  describe "#partial" do
    let(:base) do
      ValidatorRb.object(
        name: ValidatorRb.string.required,
        email: ValidatorRb.string.email.required
      )
    end

    it "skips validation for missing keys" do
      result = base.partial.validate({})

      expect(result.success?).to be true
    end

    it "still validates keys that are present" do
      result = base.partial.validate({ email: "not-an-email" })

      expect(result.success?).to be false
      expect(result.errors.map(&:code)).to eq([:invalid_email])
    end

    it "returns a new validator without mutating the original" do
      partial = base.partial

      expect(partial).not_to equal(base)
      expect(base.validate({}).success?).to be false
    end

    it "preserves the strict flag" do
      result = base.strict.partial.validate({ extra: 1 })

      expect(result.errors.map(&:code)).to include(:unknown_key)
    end
  end

  describe "#pick" do
    let(:base) do
      ValidatorRb.object(
        name: ValidatorRb.string.required,
        email: ValidatorRb.string.email.required,
        age: ValidatorRb.integer.optional
      )
    end

    it "keeps only the chosen keys" do
      picked = base.pick(%i[name email])
      result = picked.validate({ name: "Alice", email: "alice@example.com" })

      expect(result.success?).to be true
    end

    it "ignores fields that were not picked" do
      picked = base.pick([:name])
      result = picked.validate({ name: "Alice" })

      expect(result.success?).to be true
    end

    it "returns a new validator without mutating the original" do
      picked = base.pick([:name])

      expect(picked).not_to equal(base)
      expect(base.validate({ name: "Alice" }).errors.map(&:code)).to include(:required)
    end

    it "matches keys regardless of string/symbol form" do
      picked = base.pick(["name"])
      result = picked.validate({ name: "Alice" })

      expect(result.success?).to be true
    end
  end

  describe "#omit" do
    let(:base) do
      ValidatorRb.object(
        name: ValidatorRb.string.required,
        password: ValidatorRb.string.min(8).required
      )
    end

    it "drops the excluded keys" do
      public_view = base.omit([:password])
      result = public_view.validate({ name: "Alice" })

      expect(result.success?).to be true
    end

    it "still validates the remaining keys" do
      public_view = base.omit([:password])
      result = public_view.validate({})

      expect(result.errors.map(&:code)).to eq([:required])
    end

    it "returns a new validator without mutating the original" do
      public_view = base.omit([:password])

      expect(public_view).not_to equal(base)
      expect(base.validate({ name: "Alice" }).errors.map(&:code)).to include(:required)
    end
  end

  describe "#required on the object itself" do
    it "fails when the hash itself is nil" do
      validator = ValidatorRb.object(name: ValidatorRb.string.required).required
      result = validator.validate(nil)

      expect(result.success?).to be false
      expect(result.errors.first.code).to eq(:required)
    end
  end
end
