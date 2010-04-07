require "rubygems"
require "lib/utf8_utils"
require "ruby-prof"

RubyProf.measure_mode = RubyProf::MEMORY

string = "Sim\xF3n Bol\xEDvar"

RubyProf.start
1000.times do
  string.to_utf8_chars.tidy_bytes.to_s
end
result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)