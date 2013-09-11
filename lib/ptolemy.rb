# encoding: UTF-8

require "ptolemy/version"
require "ptolemy/parser"

module Ptolemy

  def self.parse(data)
    Parser.parse(data)
  end

  def self.parse_file filename
    File.open filename, 'r:utf-8' do |file|
      # TODO: Should the check for valid UTF-8 be done over here?
      return Parser.parse file.read
    end
  end

end
