require File.expand_path("../utf8_utils/byte",  __FILE__)
require File.expand_path("../utf8_utils/char",  __FILE__)
require File.expand_path("../utf8_utils/chars", __FILE__)

# Wraps a string as an array of bytes and allows some naive cleanup operations
# as a workaround for Ruby 1.9's crappy encoding support that throws exceptions
# when attempting to access UTF8 strings with invalid characters.
module UTF8Utils

  # CP1251 decimal byte => UTF-8 approximation as an array of bytes
  CP1251 = {
    128 => [226, 130, 172],
    129 => nil,
    130 => [226, 128, 154],
    131 => [198, 146],
    132 => [226, 128, 158],
    133 => [226, 128, 166],
    134 => [226, 128, 160],
    135 => [226, 128, 161],
    136 => [203, 134],
    137 => [226, 128, 176],
    138 => [197, 160],
    139 => [226, 128, 185],
    140 => [197, 146],
    141 => nil,
    142 => [197, 189],
    143 => nil,
    144 => nil,
    145 => [226, 128, 152],
    146 => [226, 128, 153],
    147 => [226, 128, 156],
    148 => [226, 128, 157],
    149 => [226, 128, 162],
    150 => [226, 128, 147],
    151 => [226, 128, 148],
    152 => [203, 156],
    153 => [226, 132, 162],
    154 => [197, 161],
    155 => [226, 128, 186],
    156 => [197, 147],
    157 => nil,
    158 => [197, 190],
    159 => [197, 184]
  }

end

# Get an array of UTF8 charsfrom a string.
class String
  def to_utf8_chars
    UTF8Utils::Chars.new self
  end
end

class Fixnum
  # Returns the offset of the first zero bit, reading from left to right.
  def first_zero_bit
    @first_zero_bit ||= if self[7] == 0 then 0
    elsif self[6] == 0 then 1
    elsif self[5] == 0 then 2
    elsif self[4] == 0 then 3
    elsif self[3] == 0 then 4
    elsif self[2] == 0 then 5
    elsif self[1] == 0 then 6
    elsif self[0] == 0 then 7
    else nil
    end
  end
end
