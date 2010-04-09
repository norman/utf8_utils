# encoding: utf-8
require "test/unit"
require File.expand_path("../../lib/utf8_utils", __FILE__)

class UTF8UtilsTest < Test::Unit::TestCase

  SINGLE_BYTE_CASES = {
    "\x21" => "!", # Valid ASCII byte, low
    "\x41" => "A", # Valid ASCII byte, mid
    "\x7E" => "~", # Valid ASCII byte, high
    "\x80" => "€",  # Continuation byte, low (cp125)
    "\x94" => "”",  # Continuation byte, mid (cp125)
    "\x9F" => "Ÿ",  # Continuation byte, high (cp125)
    "\xC0" => "À", # Overlong encoding, start of 2-byte sequence, but codepoint < 128
    "\xC1" => "Á", # Overlong encoding, start of 2-byte sequence, but codepoint < 128
    "\xC2" => "Â", # Start of 2-byte sequence, low
    "\xC8" => "È", # Start of 2-byte sequence, mid
    "\xDF" => "ß", # Start of 2-byte sequence, high
    "\xE0" => "à", # Start of 3-byte sequence, low
    "\xE8" => "è", # Start of 3-byte sequence, mid
    "\xEF" => "ï", # Start of 3-byte sequence, high
    "\xF0" => "ð", # Start of 4-byte sequence
    "\xF1" => "ñ",  # Unused byte
    "\xFF" => "ÿ", # Restricted byte
  }

  def test_should_handle_single_byte_cases
    SINGLE_BYTE_CASES.each do |bad, good|
      assert_equal good, bad.tidy_bytes.to_s
      assert_equal "#{good}#{good}", "#{bad}#{bad}".tidy_bytes
      assert_equal "#{good}#{good}#{good}", "#{bad}#{bad}#{bad}".tidy_bytes
      assert_equal "#{good}a", "#{bad}a".tidy_bytes
      assert_equal "a#{good}a", "a#{bad}a".tidy_bytes
      assert_equal "a#{good}", "a#{bad}".tidy_bytes
    end
  end

  def test_should_tidy_leading_byte_followed_by_too_few_continuation_bytes
    string = "\xF0\xA5\xA4\x21"
    assert_equal "ð¥¤!", string.tidy_bytes
  end

  def test_should_not_modifiy_valid_utf8_unless_forced
    # Nothing can be done to tidy the bytes here, because it's valid UTF-8.
    assert_not_equal "ð¥¤¤", "\xF0\xA5\xA4\xA4".tidy_bytes
    assert_not_equal "Â»", "\xC2\xBB".tidy_bytes
    assert_equal "ð¥¤¤", "\xF0\xA5\xA4\xA4".tidy_bytes(true)
    assert_equal "Â»", "\xC2\xBB".tidy_bytes(true)
  end

  def test_should_not_tidy_leading_byte_followed_by_too_many_continuation_bytes_unless_forced
    string = "\xF0\xA5\xA4\xA4\xA4"
    assert_not_equal "ð¥¤¤¤", string.tidy_bytes
    assert_equal "ð¥¤¤¤", string.tidy_bytes(true)
  end

  def test_should_tidy_bytes_in_place
    string = "\xF0\xA5\xA4\x21"
    string.tidy_bytes!
    assert_equal "ð¥¤!", string
  end

end
