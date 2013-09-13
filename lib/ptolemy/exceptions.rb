# encoding: UTF-8

module Ptolemy

  # Represents the error that occurs while parsing a TOML
  # input.
  #
  # Possible sources of error are
  # * Encoding issues
  # * Issues while parsing into AST
  # * Duplication issues
  class ParseError < StandardError; end

end
