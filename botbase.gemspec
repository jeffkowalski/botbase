# frozen_string_literal: true

require_relative "lib/botbase/version"

Gem::Specification.new do |spec|
  spec.name = "botbase"
  spec.version = Botbase::VERSION
  spec.authors = ["Jeff Kowalski"]
  spec.email = ["jeff.kowalski@gmail.com"]

  spec.summary = "Base definitions for common bots"
  spec.description = "Defines with_rescue to retry on specific errors, RecorderBotBase - a class for bots that gather data for recording to influxdb, ScannerBotBase - a class for bots that inspect sources and create notifications"
  spec.homepage = "https://github.com/jeffkowalski/botbase"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["allowed_push_host"] = "https://example.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "influxdb", "~> 0.8"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "yaml", "~> 0.2"

  spec.add_dependency "debug", "~> 1.4"
  spec.add_dependency "method_source", "~> 1.0"
  spec.add_dependency "pry", "~> 0.14"
  #spec.add_dependency "pry_doc", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
