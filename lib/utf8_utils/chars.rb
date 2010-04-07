module UTF8Utils
  class Chars

    attr :bytes
    attr :position

    include Enumerable

    def initialize(string)
      @position = 0
      begin
        # Create an array of bytes without raising an ArgumentError in 1.9.x
        # when the string contains invalid UTF-8 characters
        @bytes = string.each_byte.map {|b| Byte.new(b)}
      rescue LocalJumpError
        # 1.8.6's `each_byte` does not return an Enumerable
        @bytes = []
        string.each_byte { |b| @bytes << Byte.new(b) }
      end
    end

    # Attempt to clean up malformed characters.
    def tidy_bytes
      Chars.new(entries.map {|c| c.tidy.to_s}.compact.join)
    end

    # Cast to string.
    def to_s
      entries.flatten.map {|b| b.to_i }.pack("C*").unpack("U*").pack("U*")
    end

    def first
      entries.first
    end

    private

    def each(&block)
      while char = next_char
        yield char
      end
      @position = 0
    end

    alias :each_char :each
    public :each_char

    def next_char
      return if !bytes[position]
      char = Char.new(bytes.slice(position, bytes[position].continuations + 1))
      if char.invalid?
        char = Char.new(bytes.slice(position, 1))
      end
      @position = position + char.size
      char unless char.empty?
    end

  end
end
