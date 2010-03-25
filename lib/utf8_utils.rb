# Wraps a string as an array of bytes and allows some naive cleanup operations as a workaround
# for Ruby 1.9's crappy encoding support that throws exceptions when attempting to access
# UTF8 strings with invalid characters.
module UTF8Utils

  class Codepoints

    attr_accessor :chars
    attr :position

    include Enumerable

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

    def initialize(string)
      @position = 0
      # 1.8.6's `each_byte` does not return an Enumerable
      if RUBY_VERSION < "1.8.7"
        @chars = []
        string.each_byte { |b| @chars << b }
      else
        # Create an array of bytes without raising an ArgumentError in 1.9.x
        # when the string contains invalid UTF-8 characters
        @chars = string.each_byte.entries
      end
    end

    # Attempt to clean up malformed characters.
    def tidy_bytes
      Codepoints.new(entries.map {|c| c.tidy.to_char}.compact.join)
    end

    # Cast to string.
    def to_s
      entries.map {|e| e.to_char}.join
    end

    private

    def each(&block)
      while codepoint = next_codepoint
        yield codepoint
      end
      @position = 0
    end

    alias :each_codepoint :each
    public :each_codepoint

    def bytes_to_pull
      case chars[position]
      when 0..127 then 1
      when 128..223 then 2
      when 224..239 then 3
      else 4
      end
    end

    def next_codepoint
      codepoint = Codepoint.new(chars.slice(position, bytes_to_pull))
      if codepoint.invalid?
        codepoint = Codepoint.new(chars.slice(position, 1))
      end
      @position = position + codepoint.size
      codepoint unless codepoint.empty?
    end

  end

  class Codepoint < Array

    # Borrowed from the regexp in ActiveSupport, which in turn had been borrowed from
    # the Kconv library by Shinji KONO - (also as seen on the W3C site).
    # See also http://en.wikipedia.org/wiki/UTF-8
    def valid?
     if length == 1
       (0..127) === self[0]
     elsif length == 2
       (192..223) === self[0] &&  (128..191) === self[1]
     elsif length == 3
       (self[0] == 224 && ((160..191) === self[1] && (128..191) === self[2])) ||
       ((225..239) === self[0] && (128..191) === self[1] && (128..191) === self[2])
     elsif length == 4
       (self[0] == 240 && (144..191) === self[1] && (128..191) === self[2] && (128..191) === self[3]) ||
       ((241..243) === self[0] && (128..191) === self[1] && (128..191) === self[2] && (128..191) === self[3]) ||
       (self[0] == 244 && (128..143) === self[1] && (128..191) === self[2] && (128..191) === self[3])
     end
    end

    # Attempt to rescue a valid UTF-8 character from a malformed codepoint. It will first
    # attempt to convert from CP1251, and if this isn't possible, it prepends a valid leading
    # byte, treating the character as the last byte in a two-byte codepoint.
    # Note that much of the logic here is taken from ActiveSupport; the difference is that this
    # works for Ruby 1.8.6 - 1.9.1.
    def tidy
      return self if valid?
      if Codepoints::CP1251.key? self[0]
        self.class.new [Codepoints::CP1251[self[0]]]
      elsif self[0] < 192
        self.class.new [194, self[0]]
      else
        self.class.new [195, self[0] - 64]
      end
    end

    def invalid?
      !valid?
    end

    # Get a character from the bytes.
    def to_char
      flatten.pack("C*").unpack("U*").pack("U*")
    end

  end
end

# Get an array of UTF8 codepoints from a string.
class String
  def to_utf8_codepoints
    UTF8Utils::Codepoints.new self
  end
end