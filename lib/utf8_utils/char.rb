module UTF8Utils

  class Char < Array

    # Given the first byte, how many bytes long should this character be?
    def expected_length
      (first.continuations rescue 0) + 1
    end

    # Is the character invalid?
    def invalid?
      !valid?
    end

    # Attempt to rescue a valid UTF-8 character from a malformed character. It
    # will first attempt to convert from CP1251, and if this isn't possible, it
    # prepends a valid leading byte, treating the character as the last byte in
    # a two-byte character.  Note that much of the logic here is taken from
    # ActiveSupport; the difference is that this works for Ruby 1.8.6 - 1.9.1.
    def tidy
      return self if valid?
      byte = first.to_i
      if UTF8Utils::CP1251.key? byte
        self.class.new [UTF8Utils::CP1251[byte]]
      elsif byte < 192
        self.class.new [194, byte]
      else
        self.class.new [195, byte - 64]
      end
    end

    # Get a multibyte character from the bytes.
    def to_s
      flatten.map {|b| b.to_i }.pack("C*").unpack("U*").pack("U*")
    end

    def to_codepoint
      flatten.map {|b| b.to_i }.pack("C*").unpack("U*")[0]
    end

    def valid?
      return false if length != expected_length
      each_with_index do |byte, index|
        return false if byte.invalid?
        return false if index == 0 and byte.continuation?
        return false if index > 0 and !byte.continuation?
      end
      true
    end

  end
end
