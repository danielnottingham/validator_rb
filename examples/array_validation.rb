# frozen_string_literal: true

require_relative "../lib/validator_rb"

puts "=== Array Validation Example ==="

# 1. Basic Array Validation
puts "\n1. Basic Array Validation:"
validator = ValidatorRb.array.min_items(2).max_items(5).unique
result = validator.validate([1, 2, 3])
puts "Input: [1, 2, 3]"
puts "Valid? #{result.success?}"

result = validator.validate([1])
puts "Input: [1]"
puts "Valid? #{result.success?}"
puts "Errors: #{result.error_message}"

result = validator.validate([1, 2, 2])
puts "Input: [1, 2, 2]"
puts "Valid? #{result.success?}"
puts "Errors: #{result.error_message}"

# 2. Element Validation (Array of Emails)
puts "\n2. Element Validation (Array of Emails):"
email_validator = ValidatorRb.string.email
array_validator = ValidatorRb.array.of(email_validator)

emails = ["valid@example.com", "invalid-email", "another@example.com"]
result = array_validator.validate(emails)

puts "Input: #{emails.inspect}"
puts "Valid? #{result.success?}"
if result.failure?
  result.errors.each do |error|
    puts "- Error at index #{error.path[0]}: #{error.message} (Code: #{error.code})"
  end
end

# 3. Nested Array Validation
puts "\n3. Nested Array Validation:"
# Matrix of positive integers
inner_validator = ValidatorRb.array.of(ValidatorRb.integer.positive)
matrix_validator = ValidatorRb.array.of(inner_validator)

matrix = [
  [1, 2, 3],
  [4, -5, 6], # Error here
  [7, 8, 9]
]

result = matrix_validator.validate(matrix)
puts "Input: #{matrix.inspect}"
puts "Valid? #{result.success?}"
if result.failure?
  result.errors.each do |error|
    puts "- Error at path #{error.path}: #{error.message}"
  end
end

# 4. Transformations
puts "\n4. Transformations (Compact & Flatten):"
validator = ValidatorRb.array.compact.flatten
input = [1, nil, [2, 3], nil, [4, [5]]]
result = validator.validate(input)

puts "Input: #{input.inspect}"
puts "Output: #{result.value.inspect}"
