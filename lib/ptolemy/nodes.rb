# encoding: UTF-8

require 'set'

require 'ptolemy/exceptions'

module Ptolemy
module TOML

  class Toml < Treetop:: Runtime::SyntaxNode
    def to_value
      result = {}
      # Keep track of location under which all the key value pairs must be
      # stored. It gets modified when a key group is encountered.
      current = result
      # Store all key groups detected so that duplicates can be discovered.
      key_group_set = Set.new

      list.elements.map do |item|
        elem = item.elem
        if elem.is_a? KeyGroup
          # Reset current to root level. Key value groups always specify
          # nesting from root
          current = result
          key_group = elem.to_value
          if key_group_set.include? key_group
            raise ParseError, "Already defined [#{key_group}] before."
          end
          key_group_set.add key_group
          # If the key group is x.y.z.w, create the whole nested structure
          # in case it doesn't exist already.
          key_group.each do |key|
            current[key] = {} if current[key].nil?
            current = current[key]
          end
        else
          key, value = elem.to_value
          # Set value in hash, if it hasn't been set already.
          if current[key].nil?
            current[key] = value
          else
            raise ParseError, "Duplicate value for key:#{key}"
          end
        end
      end
      result
    end
  end

  class KeyGroup < Treetop::Runtime::SyntaxNode
    def to_value
      result = [keys.key.to_value]
      keys.remaining_keys.elements.each do |elem|
        result << elem.key.to_value
      end
      result
    end
  end

  class KeyValue < Treetop::Runtime::SyntaxNode
    def to_value
      [key.to_value, value.to_value]
    end
  end

  class Key < Treetop::Runtime::SyntaxNode
    def to_value
      text_value
    end
  end

  class Comment < Treetop::Runtime::SyntaxNode
  end

  class ArrayLiteral < Treetop::Runtime::SyntaxNode
   def to_value
      result = list.elements.map do|elem|
        elem.item.to_value
      end
      unless last.empty?
        result << last.item.to_value
      end
      result
    end
  end

  class IntegerLiteral < Treetop::Runtime::SyntaxNode
   def to_value
      text_value.to_i
    end
  end

  class FloatLiteral < Treetop::Runtime::SyntaxNode
    def to_value
      text_value.to_f
    end
  end

  class BooleanLiteral < Treetop::Runtime::SyntaxNode
    def to_value
      text_value == 'true'
    end
  end

  class StringLiteral < Treetop::Runtime::SyntaxNode

    private

    @@unescape = {
      '\b' => "\b",
      '\t' => "\t",
      '\n' => "\n",
      '\\' => "\\",
      '\f' => "\f",
      '\r' => "\r",
      '\"' => "\"",
      '\/' => "\/"
    }

    public

    def to_value
      elem = string.text_value
      # Unescape unicode characters of the form \uXXXX
      # Pack the XXXX string as hexadecimal ---> Unpack to array of integers
      # ---> Pack back into unicode
      elem.gsub!(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
      # Unescape known escape characters
      elem.gsub!(/(\\[btn\\fr"\/])/) {|m| @@unescape[m]}
      elem
    end
  end

  class DateLiteral < Treetop::Runtime::SyntaxNode
    def to_value
      args = [year, month, day, hour, min, sec].map(&:text_value).map(&:to_i)
      DateTime.new(*args)
    end
  end

end
end
