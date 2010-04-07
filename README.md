# UTF8 Utils

This library provides a means of cleaning UTF8 strings with invalid characters.

It provides functionality very similar to [ActiveSupport's `tidy_bytes`
method](http://api.rubyonrails.org/classes/ActiveSupport/Multibyte/Chars.html#M000977),
but works for Ruby 1.8.6 - 1.9.x. Once I sort out any potentially embarrassing
issues with it, I'll probably try patching it into ActiveSupport.

## The Problem

Here's what happens when you try to access a string with invalid UTF-8 characters in Ruby 1.9:

    ruby-1.9.1-p378 > "my messed up \x92 string".split(//u)
    ArgumentError: invalid byte sequence in UTF-8
            from (irb):3:in `split'
            from (irb):3
            from /Users/norman/.rvm/rubies/ruby-1.9.1-p378/bin/irb:17:in `<main>'

## The Solution

    ruby-1.9.1-p378 > "my messed up \x92 string".to_utf8_chars.tidy_bytes.to_s.split(//u)
     => ["m", "y", " ", "m", "e", "s", "s", "e", "d", " ", "u", "p", " ", "’", " ", "s", "t", "r", "i", "n", "g"]

Amazing in its brevity and elegance, huh? Ok, maybe not really but if you have
some badly encoded data you need to clean up, it can save you from ripping out
your hair.

Note that like ActiveSupport, it naively assumes if you have invalid UTF8
characters, they are either Windows CP1251 or ISO8859-1. In practice this isn't
a bad assumption, but may not always work.

Unlike ActiveSupport, however, the performance of this library is **very** poor
right now.  Since my intention is for this to be used mostly for very short
strings, it should, however, be good enough for many kinds of applications.

How poor is "very poor?" Have a look:


                               | ACTIVE_SUPPORT | UTF8_UTILS |
    ----------------------------------------------------------
    tidy bytes           x2000 |          0.087 |      1.225 |
    ==========================================================
    Total                      |          0.087 |      1.225 |


This will improve quite a bit soon, as I'm pretty well aware of where the
slowness is coming from. If performance is important for you now though, by all
means use another library (if you can find one) until I've made a few more
releases.

## Getting it

    gem install utf8_utils


## Using it

    # encoding: utf-8
    require "utf8_utils"

    # Iterate over multibyte characters
    "hello ーチエンジンの日本".to_utf8_chars.each_char do |char|
        puts char.valid?
     end

     # tidy bytes
     good_string = bad_string.to_utf8_chars.tidy_bytes.to_s

## API Docs

[http://norman.github.com/utf8_utils](http://norman.github.com/utf8_utils)

## Credits

Created by Norman Clarke. Some code was taken from
[ActiveRecord](http://github.com/rails/rails/tree/master/activesupport/), as
indicated in the source code.

Copyright (c) 2010, released under the MIT license.
