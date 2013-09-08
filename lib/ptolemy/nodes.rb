module TOML

  class Toml < Treetop:: Runtime::SyntaxNode
    def type
      :toml
    end
  end

  class KeyGroup < Treetop::Runtime::SyntaxNode
    def type
      :key_group
    end
  end

  class KeyValue < Treetop::Runtime::SyntaxNode
    def type
      :key_value
    end
  end

  class Key < Treetop::Runtime::SyntaxNode
    def type
      :key
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
  end

  class IntegerLiteral < Treetop::Runtime::SyntaxNode
    def type
      :integer
    end
  end

  class FloatLiteral < Treetop::Runtime::SyntaxNode
    def type
      :float
    end
  end

  class BooleanLiteral < Treetop::Runtime::SyntaxNode
    def type
      :boolean
    end
  end

  class StringLiteral < Treetop::Runtime::SyntaxNode
    def type
      :string
    end
  end

  class DateLiteral < Treetop::Runtime::SyntaxNode
    def type
      :date
    end
  end

end
