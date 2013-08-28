require "ptolemy/version"
require "ptolemy/parser"

module Ptolemy

  def self.parse(data)
    Parser.parse(data)
  end

end
