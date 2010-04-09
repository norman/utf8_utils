# UTF8 Utils

This library provides a means of cleaning UTF8 strings with invalid characters.

It provides functionality that replaces [ActiveSupport's `tidy_bytes`
method](http://api.rubyonrails.org/classes/ActiveSupport/Multibyte/Chars.html#M000977),
with a faster algorithm that works on 1.8.6 - 1.9.x.

I've sent this code [as a patch to
ActiveSupport](https://rails.lighthouseapp.com/projects/8994/tickets/4350-tidy_bytes-fails-on-19x);
in the mean time you can access at [its home on
Github](github.com/norman/utf8_utils).

## The Problem

Your application may have to deal with invalid UTF-8 strings that come from
user input that is copied and pasted from Microsoft Word, and includes
Windows-encoded "smart quotes," or other characters. This is only one scenario;
there are many ways your application could receive such input.

Here's what happens when you try to access a string with invalid UTF-8
characters in Ruby 1.9:

    ruby-1.9.1-p378 > "my messed up \x92 string".split(//u)
    ArgumentError: invalid byte sequence in UTF-8
            from (irb):3:in `split'
            from (irb):3
            from /Users/norman/.rvm/rubies/ruby-1.9.1-p378/bin/irb:17:in `<main>'

Ruby is quite particular about this - accessing the data in the string is
difficult as almost all string access methods will die with this error.

## The Solution

This library breaks the string down into an array of raw bytes, and cleans up
the ones that are impossible UTF-8 sequences.

    ruby-1.9.1-p378 > "my messed up \x92 string".tidy_bytes.split(//u)
     => ["m", "y", " ", "m", "e", "s", "s", "e", "d", " ", "u", "p", " ", "’", " ", "s", "t", "r", "i", "n", "g"]

Note that, like ActiveSupport, it naively assumes if you have invalid UTF8
characters, their encoding is either Windows CP1252 or ISO-8859-1. In practice
this isn't a bad assumption, but may not always work.

This library's `tidy_bytes` method is a little less than twice as fast as the
one provided by ActiveSupport:


                               | ACTIVE_SUPPORT | UTF8_UTILS |
    ----------------------------------------------------------
    tidy bytes          x20000 |          1.004 |      0.607 |
    ==========================================================
    Total                      |          1.004 |      0.607 |

## Getting it

    gem install utf8_utils


## Using it

    # encoding: utf-8
    require "utf8_utils"

    # tidy bytes
    good_string = bad_string.tidy_bytes

    # tidy bytes in-place
    string.tidy_bytes!

    # assume string is 100% ISO-8859-1 or CP-1251 and recode it to UTF-8
    good_string = bad_string.tidy_bytes(true)

## API Docs

[http://norman.github.com/utf8_utils](http://norman.github.com/utf8_utils)

## Credits

Created by Norman Clarke.

Copyright (c) 2010, released under the MIT license.
