module UTF8Utils

  # A single UTF-8 byte.
  class Byte

    attr_reader :byte

    def initialize(byte)
      @byte = byte
    end

    def codepoint_mask
      case leading_1_bits
      when 0 then 0
      when 1 then 0b1000_0000
      when 2 then 0b1100_0000
      when 3 then 0b1110_0000
      when 4 then 0b1111_0000
      end
    end

    # Is this a continuation byte?
    def continuation?
      leading_1_bits == 1
    end

    # How many continuation bytes should follow this byte?
    def continuations
      bits = leading_1_bits
      bits < 2 ? 0 : bits - 1
    end

    def invalid?
      !valid?
    end

    # From Wikipedia's entry on UTF-8:
    #
    # The UTF-8 encoding is variable-width, with each character represented by 1
    # to 4 bytes. Each byte has 0–4 leading consecutive 1 bits followed by a zero bit
    # to indicate its type. N 1 bits indicates the first byte in a N-byte sequence,
    # with the exception that zero 1 bits indicates a one-byte sequence while one 1
    # bit indicates a continuation byte in a multi-byte sequence (this was done for
    # ASCII compatibility).
    # @see http://en.wikipedia.org/wiki/Utf-8
    def leading_1_bits
      nibble = byte >> 4
      if    nibble < 0b1000 then 0 # single-byte chars
      elsif nibble < 0b1100 then 1 # continuation byte
      elsif nibble < 0b1110 then 2 # start of 2-byte char
      elsif nibble < 0b1111 then 3 # 3-byte char
      else                       4 # 4-byte char
      end
    end

    # Start of a 2-byte sequence, but code point ≤ 127
    # @see http://tools.ietf.org/html/rfc3629
    def overlong?
      (192..193) === byte
    end

    # RFC 3629 reserves 245-253 for the leading bytes of 4-6 byte sequences.
    # @see http://tools.ietf.org/html/rfc3629
    def restricted?
      (245..253) === byte
    end

    def to_i
      byte
    end

    # Bytes 254 and  255 are not defined by the original UTF-8 spec.
    def undefined?
      (254..255) === byte
    end

    def valid?
      !(overlong? or restricted? or undefined?)
    end

    def codepoint_bits
      byte ^ codepoint_mask
    end

  end
end