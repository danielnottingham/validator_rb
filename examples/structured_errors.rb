require_relative "../lib/validator_rb"

puts "=== Structured Error Handling Example ==="

# 1. Basic Validation Failure
puts "\n1. Basic Validation Failure:"
validator = ValidatorRb.string.min(5).email
result = validator.validate("hi")

if result.failure?
  error = result.errors.first
  puts "Error Object: #{error.inspect}"
  puts "Message: #{error.message}"
  puts "Code:    #{error.code}"
  puts "Path:    #{error.path}"
  puts "Meta:    #{error.meta}"
end

# 2. Using Error Codes for Custom Logic (Simulated I18n)
puts "\n2. Using Error Codes for Custom Logic (Simulated I18n):"

def translate_error(error)
  translations = {
    too_short: "O valor é muito curto (mínimo de 5 caracteres)",
    invalid_email: "O formato do email é inválido",
    required: "Este campo é obrigatório"
  }
  translations[error.code] || error.message
end

validator = ValidatorRb.string.min(5).email
result = validator.validate("hi")

result.errors.each do |error|
  puts "Original: #{error.message}"
  puts "Translated: #{translate_error(error)}"
end

# 3. Handling Multiple Errors
puts "\n3. Handling Multiple Errors:"
validator = ValidatorRb.string.min(10).max(5).email
result = validator.validate("invalid")

result.errors.each do |error|
  puts "- [#{error.code}] #{error.message}"
end

# 4. Integer Validation Errors
puts "\n4. Integer Validation Errors:"
validator = ValidatorRb.integer.positive.even
result = validator.validate(-3)

result.errors.each do |error|
  puts "- [#{error.code}] #{error.message}"
end
