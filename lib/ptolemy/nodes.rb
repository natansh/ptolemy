# encoding: UTF-8

require 'set'

require 'ptolemy/exceptions'

module Ptolemy
module TOML

  # Represents the top level node of TOML AST
  class Toml < Treetop:: Runtime::SyntaxNode

    # Evaluate the individual subtrees of the AST
    # and then combine them to form the complete hash.
    #
    # @return [Hash] a (possibly nested) hash containing all
    #   key value pairs.
    # @raise [ParseError] if there are duplications in
    #   key groups or key value pairs.
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

  # Represents an element of the form [x.y.z.w]
  class KeyGroup < Treetop::Runtime::SyntaxNode

    # Evaluate an array of keys split by the '.'
    #
    # @return [Array] the array of nested keys represented by the key group
    def to_value
      result = [keys.key.to_value]
      keys.remaining_keys.elements.each do |elem|
        result << elem.key.to_value
      end
      result
    end
  end

  # Represents an element of the form key = value
  class KeyValue < Treetop::Runtime::SyntaxNode

    # Evaluate both key and value and return as a 2 element array
    #
    # @return [Array] Two-element array containing key and value
    def to_value
      [key.to_value, value.to_value]
    end
  end

  # Represents a valid key
  class Key < Treetop::Runtime::SyntaxNode

    # Evaluates the key which is just the text_value of the node
    def to_value
      text_value
    end
  end

  # Represents a Comment
  class Comment < Treetop::Runtime::SyntaxNode
  end

  # Represents a homogeneous array. Mixing of types is not allowed
  # for elements of an array.
  #
  # * [1, 2, 3, 4]
  # * ["Hello", "World"]
  # * [ ["Alpha", "Beta"], [1, 2]] <-- This is fine
  class ArrayLiteral < Treetop::Runtime::SyntaxNode

    # Evaluate the array by mapping the individual elements
    # of the array to their evaluated selves.
    #
    # @return [Array] evaluated array
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

  # Represents an integer. Ruby doesn't have overflow issues
  # so any big integer is going to be fine.
  class IntegerLiteral < Treetop::Runtime::SyntaxNode

    # Evaluate an integer by converting the text_value to
    # integer directly.
    #
    # @return [Integer] evaluated integer
    def to_value
      text_value.to_i
    end
  end

  # Represents a Float
  class FloatLiteral < Treetop::Runtime::SyntaxNode

    # Evaluate a float by converting the text_value to a
    # float directly
    #
    # @return [Float] evaluated float
    def to_value
      text_value.to_f
    end
  end

  # Represents a Boolean
  class BooleanLiteral < Treetop::Runtime::SyntaxNode

    # Evaluate a boolean by checking whether its
    # text value matches true
    #
    # @return [true, false] evaluated boolean
    def to_value
      text_value == 'true'
    end
  end

  # Represents a UTF-8 encoded string
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

    # Evaluate a string by unescaping the escaped characters and
    # unicode characters written in the form \uXXXX
    #
    # @return [String] evaluated string
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

    # Evaluate the date by extracting individual elements such as year, month etc.
    # from the parsed date and using that to construct a {DateTime} object.
    #
    # @return [DateTime] the evaluated date represented by the elements
    def to_value
      args = [year, month, day, hour, min, sec].map(&:text_value).map(&:to_i)
      DateTime.new(*args)
    end
  end

end
end
