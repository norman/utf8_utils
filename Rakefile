require "rake"
require "rake/testtask"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/clean"

CLEAN << "pkg" << "doc" << "coverage" << ".yardoc"

Rake::GemPackageTask.new(eval(File.read("utf8_utils.gemspec"))) { |pkg| }
Rake::TestTask.new(:test) { |t| t.pattern = "test/**/*_test.rb" }

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.options = ["--output-dir=doc"]
    t.options << "--files" << "README.md"
  end
rescue LoadError
end

Rake::RDocTask.new do |r|
  r.rdoc_dir = "doc"
  r.rdoc_files.include "lib/**/*.rb"
end

begin
  require "rcov/rcovtask"
  Rcov::RcovTask.new do |r|
    r.test_files = FileList["test/**/*_test.rb"]
    r.verbose = true
    r.rcov_opts << "--exclude gems/*"
  end
rescue LoadError
end
