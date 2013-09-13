![Ptolemy](https://raw.github.com/natansh/ptolemy/master/ptolemy.jpg)

[![Build Status](https://travis-ci.org/natansh/ptolemy.png?branch=master)](https://travis-ci.org/natansh/ptolemy)
[![Gem Version](https://badge.fury.io/rb/ptolemy.png)](http://badge.fury.io/rb/ptolemy)

===
`Ptolemy` is a simple TOML parser for Ruby, based on Treetop. It is useful for parsing the [TOML Format](https://github.com/mojombo/toml).

`Ptolemy` currently supports version [0.1.0](https://github.com/mojombo/toml/blob/master/versions/toml-v0.1.0.md) of TOML.

Installation
---
### Bundler
Add this to your `Gemfile`

    gem 'ptolemy'

And then run

    bundle install

### Manual
You can install it manually using

    gem install ptolemy

Usage
---
* `Ptolemy.parse` can parse a string in TOML format.

  ```ruby
  data = <<END
  # This is an example TOML input
  [group]
  string = "hello"
  integer = 0
  END

  Ptolemy.parse(data)

  # => {"group"=>{"string"=>"hello", "integer"=>0}}

  ```
* `Ptolemy.parse_file` can read from a UTF-8 encoded file directly.

  ```ruby
  filename = 'example.toml'
  Ptolemy.parse_file(filename)
  ```

Test Suite
---
`Ptolemy` has a fairly exhaustive test suite built on `rspec` and can
successfully parse the specification file and hard example given
in the TOML specification.

You can run the test suite by running `rake`.
