# encoding: UTF-8

require_relative 'spec_helper'

describe Ptolemy::TOMLParser do

  before :all do
    @parser = Ptolemy::TOMLParser.new
  end

  describe 'Literals' do
    describe 'String' do
      it 'should parse an empty string' do
        result = @parser.parse('""', root: :string)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::StringLiteral)
        result.should have_value("")
      end

      it 'should parse a simple string' do
        result = @parser.parse('"This is a string"', root: :string)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::StringLiteral)
        result.should have_value("This is a string")
      end

      it 'should parse a string having escaped characters' do
        result = @parser.parse('"This is an \n\t \bescaped string."', root: :string)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::StringLiteral)
        result.should have_value("This is an \n\t \bescaped string.")
      end

      it 'should parse a string having unicode symbols' do
        result = @parser.parse('"This is a string containing úƞĩƈōƌě symbols."', root: :string)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::StringLiteral)
        result.should have_value( "This is a string containing úƞĩƈōƌě symbols.")
      end

      it 'should parse a string having escaped unicode characters' do
        result = @parser.parse('"This is a unicode string containing linefeed as \u000A."', root: :string)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::StringLiteral)
        result.should have_value( "This is a unicode string containing linefeed as \n.")
      end

      it 'should not parse a string with single quotes' do
        result = @parser.parse("'Hello World!'", root: :string)
        result.should be_nil
      end
    end

    it 'should parse a correct float' do
      ['-0.0', '1.4', '123.2', '+1.1', '+123.9' ].each do |float|
        result = @parser.parse(float, root: :float)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::FloatLiteral)
        result.should have_value(float.to_f)
      end
    end

    it 'should parse a correct integers' do
      ['-1', '1', '123', '+1', '+123' ].each do |integer|
        result = @parser.parse(integer, root: :integer)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::IntegerLiteral)
        result.should have_value(integer.to_i)
      end
    end

    it 'should parse a correct boolean' do
      ['true', 'false' ].each do |boolean|
        result = @parser.parse(boolean, root: :boolean)
        result.should_not be_nil
        result.should be_a_kind_of(Ptolemy::TOML::BooleanLiteral)
        result.should have_value((boolean == 'true'))
      end
    end

    it 'should parse a correct date' do
      result = @parser.parse('1979-05-27T07:32:00Z', root: :date)
      result.should_not be_nil
      result.should be_a_kind_of(Ptolemy::TOML::DateLiteral)
      result.should have_value(DateTime.new(1979, 5, 27, 7, 32, 0))
    end

    it 'should not parse an incorrect date' do
      result = @parser.parse('1979-05-27T07:32:00', root: :date)
      result.should be_nil
    end
  end

  describe 'Array' do
    it 'should parse a simple array' do
      array_string = '[1, 2, 3]'
      result = @parser.parse(array_string, root: :array)
      result.should_not be_nil
      result.should be_a_kind_of(Ptolemy::TOML::ArrayLiteral)
      result.should have_value([1, 2, 3])
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
      result.should be_a_kind_of(Ptolemy::TOML::ArrayLiteral)
      result.should have_value([1, 2, 4])
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
      result.should be_a_kind_of(Ptolemy::TOML::ArrayLiteral)
      result.should have_value([[1, 2, 3], ["hello", "world"]])
    end
  end

  describe 'comment' do
    it 'should parse a correct comment' do
      result = @parser.parse('# This is a comment', root: :comment)
      result.should_not be_nil
      result.text_value.should eql '# This is a comment'
      result.should be_a_kind_of(Ptolemy::TOML::Comment)
    end
  end

  describe 'Constructs' do
    it 'should parse a key' do
      result = @parser.parse('hello', root: :key)
      result.should_not be_nil
      result.should be_a_kind_of(Ptolemy::TOML::Key)
    end

    it 'should parse a value' do
      examples = {
        '"hello"' => [Ptolemy::TOML::StringLiteral, 'hello'],
        '-1.0' => [Ptolemy::TOML::FloatLiteral, -1.0],
        '1' => [Ptolemy::TOML::IntegerLiteral, 1],
        'true' => [Ptolemy::TOML::BooleanLiteral, true],
        '1979-05-27T07:32:00Z' => [Ptolemy::TOML::DateLiteral, DateTime.new(1979, 5, 27, 7, 32, 0)]
      }

      examples.each do |input, details|
        klass, value = details
        result = @parser.parse(input, root: :value)
        result.should_not be_nil
        result.should be_a_kind_of(klass)
        result.should have_value(value)
      end
    end

    it 'should parse a correct key value' do
      examples = {
        'string' => '"Hello"',
        'date' => '1979-05-27T07:32:00Z',
        'integer' => '114',
        'float' => '1.0'
      }
      examples.each do |key, value|
        result = @parser.parse("#{key} =    \t #{value}", root: :key_value)
        result.should_not be_nil
        result.key.text_value.should eql key
        result.value.text_value.should eql value
        result.should be_a_kind_of(Ptolemy::TOML::KeyValue)
        result.should respond_to(:to_value)
        result.to_value[0].should eql key
      end
    end

    it 'should parse a correct key group' do
      result = @parser.parse('[key.hello.while]', root: :key_group)
      result.should_not be_nil
      result.should be_a_kind_of(Ptolemy::TOML::KeyGroup)
      result.should have_value(['key', 'hello', 'while'])
    end

    it 'should not parse a key group having empty key' do
      result = @parser.parse('[key..while]', root: :key_group)
      result.should be_nil
    end

    it 'should parse valid toml' do
      toml_string = <<TS_END
description = "This is valid TOML."
[personal.details]
name = "John Doe"
height = 186
date_of_birth = 1990-04-12T05:30:00Z
favorites = ["sports", "gaming"]
TS_END
      result = @parser.parse(toml_string)
      result.should_not be_nil
      result.should be_a_kind_of(Ptolemy::TOML::Toml)
      result.should respond_to(:to_value)

      toml = result.to_value
      toml['description'].should eql('This is valid TOML.')
      toml['personal'].should be_a_kind_of(Hash)
      details = toml['personal']['details']
      details.should_not be_nil
      details.should be_a_kind_of(Hash)
      details['name'].should eql('John Doe')
      details['height'].should eql(186)
      details['date_of_birth'].should eql(DateTime.new(1990, 4, 12, 5, 30, 0))
      details['favorites'].should be_a_kind_of(Array)
      details['favorites'].should eql(["sports", "gaming"])
    end
  end

end
