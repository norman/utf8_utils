# Utilities for cleaning up UTF-8 strings with invalid characters.
module UTF8Utils

  # CP1252 decimal byte => UTF-8 approximation as an array of bytes
  CP1252 = {
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

  # A mixin to Ruby's String class to add the {#tidy_bytes} and {#tidy_bytes!}
  # methods.
  module StringExt

    # Attempt to replace invalid UTF-8 bytes with valid ones. This method
    # naively assumes if you have invalid UTF8 bytes, they are either Windows
    # CP1251 or ISO8859-1. In practice this isn't a bad assumption, but may not
    # always work.
    def tidy_bytes

      bytes = unpack("C*")
      continuation_bytes_expected = 0

      bytes.each_index do |index|

        byte = bytes[index]

        is_continuation_byte = byte[7] == 1 && byte[6] == 0
        is_ascii_byte = byte[7] == 0
        is_leading_byte = byte[7] == 1 && byte[6] == 1

        if is_continuation_byte
          if continuation_bytes_expected > 0
            continuation_bytes_expected = continuation_bytes_expected - 1
          else
            # Not expecting a continuation, so clean it
            bytes[index] = tidy_byte(byte)
          end
        # ASCII byte
        elsif is_ascii_byte
          if continuation_bytes_expected > 0
            # Expected continuation, got ASCII, so clean previous
            bytes[index - 1] = tidy_byte(bytes[index - 1])
            continuation_bytes_expected = 0
          end
        elsif is_leading_byte
          if continuation_bytes_expected > 0
            # Expected continuation, got leading, so clean previous
            bytes[index - 1] = tidy_byte(bytes[index - 1])
            continuation_bytes_expected = 0
          end
          continuation_bytes_expected =
            if    byte[5] == 0 then 1
            elsif byte[4] == 0 then 2
            elsif byte[3] == 0 then 3
          end
        end
        # Don't allow the string to terminate with a leading byte
        if is_leading_byte && index == bytes.length - 1
          bytes[index] = tidy_byte(bytes.last)
        end
      end
      bytes.empty? ? "" : bytes.flatten.compact.pack("C*").unpack("U*").pack("U*")
    end

    # Tidy bytes in-place.
    def tidy_bytes!
      replace tidy_bytes
    end

    private

    def tidy_byte(byte)
      if UTF8Utils::CP1252.key? byte
        UTF8Utils::CP1252[byte]
      elsif byte < 192
        [194, byte]
      else
        [195, byte - 64]
      end
    end
  end
end

class String
  include UTF8Utils::StringExt
end
