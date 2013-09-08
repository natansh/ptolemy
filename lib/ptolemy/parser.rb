require 'treetop'

require 'ptolemy/nodes'

module Ptolemy

  class Parser

    # Load TOML grammar into Treetop
    base_path = File.expand_path(File.dirname(__FILE__))
    Treetop.load(File.join(base_path, 'toml.tt'))

    # Treetop would've generated a parser for TOML based on the grammar
    @@parser = TOMLParser.new

    def self.parse(data)
      tree = @@parser.parse(data)

      if tree.nil?
        raise Exception, "Parse error at offset: #{@@parser.index}"
      end

      tree.to_value
    end

  end

end
