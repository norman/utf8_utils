# encoding: utf-8
require "test/unit"
require File.expand_path("../../lib/utf8_utils", __FILE__)

class UTF8UtilsTest < Test::Unit::TestCase

  CASES = {
    "Sim\xF3n Bol\xEDvar" => "Simón Bolívar", # utf-8 leading bytes followed by an ascii char (fix as CP1252)
    "\xBFhola?" => "¿hola?", # iso-8859-1 inverted question mark
    "\xFF" => "something"
  }

  def test_tidy_bytes
    CASES.each do |bad, good|
      assert_equal good, bad.tidy_bytes
    end
  end

end