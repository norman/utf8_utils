require "rubygems"
require "rbench"
require "active_support"
require "lib/utf8_utils"

TIMES = 2000

string = "Sim\xF3n Bol\xEDvar"
ar_string = ActiveSupport::Multibyte::Chars.new(string)

RBench.run(TIMES) do

  column :times
  column :active_support
  column :utf8_utils

  report 'tidy bytes', (TIMES).ceil do
    active_support { ar_string.tidy_bytes.to_s }
    utf8_utils { string.to_utf8_chars.tidy_bytes.to_s }
  end

  summary 'Total'
end
