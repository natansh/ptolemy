module TOML

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
