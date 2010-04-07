require File.join(File.dirname(__FILE__), "lib", "utf8_utils", "version")

spec = Gem::Specification.new do |s|
  s.name              = "utf8_utils"
  s.rubyforge_project = "utf8_utils"
  s.version           = UTF8Utils::Version::STRING
  s.authors           = "Norman Clarke"
  s.email             = "norman@njclarke.com"
  s.homepage          = "http://norman.github.com/utf8_utils"
  s.summary           = "Utilities for cleaning up UTF8 strings."
  s.description       = "Utilities for cleaning up UTF8 strings. Compatible with Ruby 1.8.6 - 1.9.x"
  s.has_rdoc          = true
  s.test_files        = Dir.glob "test/**/*_test.rb"
  s.files             = Dir["lib/**/*.rb", "lib/**/*.rake", "*.md", "LICENSE", "Rakefile", "test/**/*.*"]

  s.add_development_dependency "mocha"

end