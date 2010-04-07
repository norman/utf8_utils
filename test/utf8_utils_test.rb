# encoding: utf-8

require "rubygems"
require "test/unit"
require "mocha"
require File.expand_path("../../lib/utf8_utils", __FILE__)

module UTF8ByteTest

  def test_leading_1_bits
    [0, 128, 194, 224, 240].each_with_index do |n, i|
      byte = UTF8Utils::Byte.new(n)
      assert_equal i, byte.leading_1_bits
    end
  end

  def test_invalid_bytes
    [192, 193, 245, 255].each do |n|
      assert !UTF8Utils::Byte.new(n).valid?
    end
  end

  def test_continuation
    assert UTF8Utils::Byte.new(130).continuation?
  end

end

class UTF8UtilsTest < Test::Unit::TestCase

  include UTF8ByteTest

  def test_entries_should_be_one_byte_for_ascii_char
    assert_equal 1, "a".to_utf8_chars.first.length
  end

  def test_entries_should_be_two_bytes_for_latin_char_with_diacritics
    assert_equal 2, "¡".to_utf8_chars.first.length
  end

  def test_entries_should_be_three_bytes_for_basic_multilingual_char
    assert_equal 3, "आ".to_utf8_chars.first.length
  end

  def test_entries_should_be_four_bytes_for_other_chars
    u = UTF8Utils::Chars.new("")
    # Editors tend to freak out with chars in this plane, so just stub the
    # chars field instead. This char is U+10404, DESERET CAPITAL LETTER LONG O.
    u.stubs(:bytes).returns([240, 144, 144, 132].map { |b| UTF8Utils::Byte.new(b)})
    assert_equal 4, u.first.length
  end

  def test_should_detect_valid_chars
    "cañón आ".to_utf8_chars.each_char {|c| assert c.valid? }
  end

  def test_should_detect_invalid_chars
    "\x92".to_utf8_chars.each_char {|c| assert c.invalid? }
  end

  def test_should_split_correctly_with_invalid_chars
    assert_equal 3, "a\x92a".to_utf8_chars.entries.length
  end

  def test_should_tidy_bytes
    assert_equal "a’a", "a\x92a".to_utf8_chars.tidy_bytes.to_s
    assert_equal "Simón Bolívar", "Sim\xF3n Bol\xEDvar".to_utf8_chars.tidy_bytes.to_s
  end

end
