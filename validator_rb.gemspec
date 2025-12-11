# frozen_string_literal: true

require_relative "lib/validator_rb/version"

Gem::Specification.new do |spec|
  spec.name = "validator_rb"
  spec.version = ValidatorRb::VERSION
  spec.authors = ["Daniel Nottingham"]
  spec.email = ["danielnottingham.ti@gmail.com"]

  spec.summary = "Schema validation with fluent API inspired by Zod."
  spec.description = "A learning project to understand Ruby gems, DSLs and method chaining through a Zod-like validation library."
  spec.homepage = "https://github.com/danielnottingham/validator_rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_development_dependency "debug", "~> 1.9"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "webrick", "~> 1.8"
  spec.add_development_dependency "yard", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
