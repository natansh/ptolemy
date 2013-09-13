# encoding: UTF-8

require "ptolemy/version"
require "ptolemy/parser"

module Ptolemy

  # Parses TOML string input
  #
  #   Ptolemy.parse 'key = "value"'
  #
  # @param data [String] the input string
  # @return [Hash] the input parsed into a ruby hash
  def self.parse data
    Parser.parse data
  end

  # Parses data from a file containing TOML.
  # The file should be UTF-8 encoded.
  #
  #   Ptolemy.parse_file 'example.toml'
  #
  # @param filename [String] full path of the file
  # @return [Hash] the input parsed into a ruby hash
  def self.parse_file filename
    File.open filename, 'r:utf-8' do |file|
      # TODO: Should the check for valid UTF-8 be done over here?
      return Parser.parse file.read
    end
  end

end
