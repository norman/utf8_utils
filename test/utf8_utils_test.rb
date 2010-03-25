# encoding: utf-8

require "test/unit"
require File.join(File.dirname(__FILE__), "..", "lib", "utf8_utils")

class UTF8CodepointsTest < Test::Unit::TestCase

  def test_should_pull_one_byte_for_ascii_char
    assert_equal 1, "a".to_utf8_codepoints.entries[0].length
  end

  def test_should_pull_two_bytes_for_latin_char_with_diacritics
    assert_equal 2, "¡".to_utf8_codepoints.entries[0].length
  end

  def test_should_pull_three_bytes_for_basic_multilingual_char
    assert_equal 3, "आ".to_utf8_codepoints.entries[0].length
  end

  def test_should_pull_four_bytes_for_other_chars
    u = UTF8Utils::Codepoints.new("")
    # Editors tend to freak out with chars in this plane, so just stub the
    # chars field instead. This char is U+10405, DESERET CAPITAL LETTER LONG OO.
    u.chars = [240, 144, 144, 132]
    assert_equal 4, u.entries[0].length
  end

  def test_should_detect_valid_codepoints
    "cañón आ".to_utf8_codepoints.each_codepoint {|c| assert c.valid? }
  end

  def test_should_detect_invalid_codepoints
    "\x92".to_utf8_codepoints.each_codepoint {|c| assert c.invalid? }
  end

  def test_should_split_correctly_with_invalid_codepoints
    assert_equal 3, "a\x92a".to_utf8_codepoints.entries.length
  end

  def test_should_tidy_bytes
    assert_equal "a’a", "a\x92a".to_utf8_codepoints.tidy_bytes.to_s
  end

  def test_should_not_screw_up_valid_strings
    s = File.read(__FILE__)
    assert_equal s.to_s, s.to_utf8_codepoints.tidy_bytes.to_s
  end

end
