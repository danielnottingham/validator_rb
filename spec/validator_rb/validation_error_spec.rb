# frozen_string_literal: true

require "spec_helper"

RSpec.describe ValidatorRb::ValidationError do
  describe "#initialize" do
    it "sets attributes correctly" do
      error = described_class.new("message", :code, path: [:field], meta: { count: 1 })

      expect(error.message).to eq("message")
      expect(error.code).to eq(:code)
      expect(error.path).to eq([:field])
      expect(error.meta).to eq({ count: 1 })
    end

    it "uses default values for path and meta" do
      error = described_class.new("message", :code)

      expect(error.path).to eq([])
      expect(error.meta).to eq({})
    end
  end

  describe "#to_h" do
    it "returns a hash representation" do
      error = described_class.new("message", :code, path: [:field], meta: { count: 1 })

      expect(error.to_h).to eq({
                                 message: "message",
                                 code: :code,
                                 path: [:field],
                                 meta: { count: 1 }
                               })
    end
  end

  describe "#==" do
    it "returns true for equal errors" do
      error1 = described_class.new("message", :code)
      error2 = described_class.new("message", :code)

      expect(error1).to eq(error2)
    end

    it "returns false for different errors" do
      error1 = described_class.new("message", :code)
      error2 = described_class.new("other", :code)

      expect(error1).not_to eq(error2)
    end
  end
end
