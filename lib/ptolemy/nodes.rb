# encoding: UTF-8

module TOML

  class Toml < Treetop:: Runtime::SyntaxNode
    def type
      :toml
    end

    def to_value
      require 'set'
      result = {}
      current = result
      key_group_set = Set.new
      list.elements.map do |item|
        elem = item.elem
        if elem.type == :key_group
          current = result
          key_group = elem.to_value

          key_group_dot = key_group.join('.')

          if key_group_set.include? key_group_dot
            raise Exception, "Already defined [#{key_group_dot}] before."
          end

          key_group_set.add key_group_dot

          key_group.each do |key|
            current[key] = {} if current[key].nil?
            current = current[key]
          end
        else
          key, value = elem.to_value
          if current[key].nil?
            current[key] = value
          else
            raise Exception, "Duplicate value for key:#{key}"
          end
        end
      end
      p result
      result
    end
  end

  class KeyGroup < Treetop::Runtime::SyntaxNode
    def type
      :key_group
    end

    def to_value
      result = [keys.key.to_value]
      keys.remaining_keys.elements.each do |elem|
        result << elem.key.to_value
      end
      result
    end
  end

  class KeyValue < Treetop::Runtime::SyntaxNode
    def type
      :key_value
    end

    def to_value
      [key.to_value, value.to_value]
    end
  end

  class Key < Treetop::Runtime::SyntaxNode
    def type
      :key
    end

    def to_value
      text_value
    end
  end

  class Comment < Treetop::Runtime::SyntaxNode
    def type
      :comment
    end
  end

  class ArrayLiteral < Treetop::Runtime::SyntaxNode
    def type
      :array
    end

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
    def type
      :integer
    end

    def to_value
      text_value.to_i
    end
  end

  class FloatLiteral < Treetop::Runtime::SyntaxNode
    def type
      :float
    end

    def to_value
      text_value.to_f
    end
  end

  class BooleanLiteral < Treetop::Runtime::SyntaxNode
    def type
      :boolean
    end

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

    def type
      :string
    end

    def to_value
      elem = string.text_value
      elem.gsub!(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
      elem.gsub!(/(\\[btn\\fr"\/])/) {|m| @@unescape[m]}
      elem
    end
  end

  class DateLiteral < Treetop::Runtime::SyntaxNode
    def type
      :date
    end

    def to_value
      args = [year, month, day, hour, min, sec].map(&:text_value).map(&:to_i)
      DateTime.new(*args)
    end
  end

end
