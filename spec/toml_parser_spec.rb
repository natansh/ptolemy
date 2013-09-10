# encoding: UTF-8

require_relative 'spec_helper'

describe TOMLParser do

  before :all do
    @parser = TOMLParser.new
  end

  describe 'Literals' do
    it 'should parse a correct string' do
      result = @parser.parse('"This is a string"', root: :string)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :string
      result.should respond_to(:to_value)
      result.to_value.should eql "This is a string"
    end

    it 'should parse a correct float' do
      ['-0.0', '1.4', '123.2', '+1.1', '+123.9' ].each do |float|
        result = @parser.parse(float, root: :float)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :float
        result.should respond_to(:to_value)
        result.to_value.should eql float.to_f
      end
    end

    it 'should parse a correct integers' do
      ['-1', '1', '123', '+1', '+123' ].each do |integer|
        result = @parser.parse(integer, root: :integer)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :integer
        result.should respond_to(:to_value)
        result.to_value.should eql integer.to_i
      end
    end

    it 'should parse a correct boolean' do
      ['true', 'false' ].each do |boolean|
        result = @parser.parse(boolean, root: :boolean)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :boolean
        result.should respond_to(:to_value)
        result.to_value.should eql (boolean == 'true')
      end
    end

    it 'should parse a correct date' do
      result = @parser.parse('1979-05-27T07:32:00Z', root: :date)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :date
      result.should respond_to(:to_value)
      result.to_value.should eql DateTime.new(1979, 5, 27, 7, 32, 0)
    end
  end

  describe 'Array' do
    it 'should parse a simple array' do
      array_string = '[1, 2, 3]'
      result = @parser.parse(array_string, root: :array)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :array
      result.should respond_to(:to_value)
      result.to_value.should eql [1, 2, 3]
    end

    it 'should parse a complex multi-line array' do
        array_string = <<AS_END
[ # Evil, must say
1,

     2        ,
# Wait, you can put comments anywhere?

4 ,
# What the... is this right?
]
AS_END
      array_string.chomp! #Heredoc introduces a newline at the end

      result = @parser.parse(array_string, root: :array)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :array
      result.should respond_to(:to_value)
      result.to_value.should eql [1, 2, 4]
    end

    it 'should parse a nested array' do
      array_string = <<AS_END
[
  [1, 2,
  # Nested comment, yeah!
  3 ],
  ["hello", "world"
    # Now this is a doozy!
  ]
]
AS_END
      array_string.chomp! #Heredoc introduces a newline at the end

      result = @parser.parse(array_string, root: :array)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :array
      result.should respond_to(:to_value)
      result.to_value.should eql [[1, 2, 3], ["hello", "world"]]
    end
  end

  describe 'comment' do
    it 'should parse a correct comment' do
      result = @parser.parse('# This is a comment', root: :comment)
      result.should_not be_nil
      result.text_value.should eql '# This is a comment'
      result.should respond_to(:type)
      result.type.should eql :comment
    end
  end

  describe 'Constructs' do
    it 'should be able to parse a key' do
      result = @parser.parse('hello', root: :key)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :key
    end

    it 'should be able to parse a value' do
      examples = {
        '"hello"' => :string,
        '-1.0' => :float,
        '1' => :integer,
        'true' => :boolean,
        '1979-05-27T07:32:00Z' => :date
      }

      examples.each do |value, type|
        result = @parser.parse(value, root: :value)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql type
      end
    end

    it 'should be able to parse a correct key value' do
      examples = {
        'string' => '"Hello"',
        'date' => '1979-05-27T07:32:00Z',
        'integer' => '114',
        'float' => '1.0'
      }
      examples.each do |key, value|
        result = @parser.parse("      #{key} =    #{value}    ", root: :key_value)
        result.should_not be_nil
        result.key.text_value.should eql key
        result.value.text_value.should eql value
        result.should respond_to(:type)
        result.type.should eql :key_value
        result.should respond_to(:to_value)
        result.to_value[0].should eql key
      end
    end

    it 'should be able to parse a correct key group' do
      result = @parser.parse('       [key.hello.while]     ', root: :key_group)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :key_group
      result.should respond_to(:to_value)
      result.to_value.should eql ['key', 'hello', 'while']
    end
  end

  it 'should parse the full TOML example files' do
    filenames = ['example.toml', 'hard_example.toml']
    filenames.each do |filename|
      path = File.expand_path(File.join(File.dirname(__FILE__), filename))
      File.open(path) do |file|
        result = @parser.parse(file.read)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :toml
      end
    end
  end

end
