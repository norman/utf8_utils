require "rubygems"
require "rbench"
require "active_support"
require "lib/utf8_utils"

TIMES = 20000

string = "\270\236\010\210\245"
ar_string = ActiveSupport::Multibyte::Chars.new(string)

RBench.run(TIMES) do

  column :times
  column :active_support
  column :utf8_utils

  report 'tidy bytes', (TIMES).ceil do
    active_support { ar_string.tidy_bytes.to_s }
    utf8_utils { string.tidy_bytes }
  end

  summary 'Total'
end