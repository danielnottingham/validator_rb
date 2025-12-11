# frozen_string_literal: true

require_relative "../lib/validator_rb"

# Example: User Registration Form Validation

puts "=" * 60
puts "Example: User Registration Form"
puts "=" * 60
puts ""

# Define validators for each field
username_validator = ValidatorRb.string
                                .trim
                                .min(3, message: "Username must be at least 3 characters")
                                .max(20, message: "Username cannot exceed 20 characters")
                                .alphanumeric(message: "Username can only contain letters and numbers")
                                .required

email_validator = ValidatorRb.string
                             .trimmed_email
                             .required

password_validator = ValidatorRb.string
                                .min(8, message: "Password must be at least 8 characters")
                                .max(128, message: "Password cannot exceed 128 characters")
                                .required

name_validator = ValidatorRb.string
                            .trim
                            .min(1, message: "Name is required")
                            .max(100, message: "Name cannot exceed 100 characters")
                            .required

# Simulate user input
user_data = {
  username: "  john_doe123!  ",  # Invalid: contains special char
  email: "  JOHN@EXAMPLE.COM  ", # Valid: will be trimmed and lowercased
  password: "pass",                # Invalid: too short
  name: "  John Doe  "             # Valid: will be trimmed
}

puts "Validating user input..."
puts ""

# Validate each field
results = {
  username: username_validator.validate(user_data[:username]),
  email: email_validator.validate(user_data[:email]),
  password: password_validator.validate(user_data[:password]),
  name: name_validator.validate(user_data[:name])
}

# Display results
results.each do |field, result|
  puts "#{field.to_s.capitalize}:"
  puts "  Input:  #{user_data[field].inspect}"
  puts "  Output: #{result.value.inspect}"
  puts "  Status: #{result.success? ? "✓ Valid" : "✗ Invalid"}"

  if result.failure?
    result.errors.each do |error|
      puts "    • #{error}"
    end
  end

  puts ""
end

# Check overall validation
all_valid = results.values.all?(&:success?)
puts "=" * 60
puts all_valid ? "✓ All fields valid!" : "✗ Validation failed"
puts "=" * 60
