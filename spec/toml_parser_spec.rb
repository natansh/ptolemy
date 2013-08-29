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
    end

    it 'should parse a correct float' do
      ['-0.0', '1.4', '123.2', '+1.1', '+123.9' ].each do |float|
        result = @parser.parse(float, root: :float)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :float
      end
    end

    it 'should parse a correct integers' do
      ['-1', '1', '123', '+1', '+123' ].each do |integer|
        result = @parser.parse(integer, root: :integer)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :integer
      end
    end

    it 'should parse a correct boolean' do
      ['true', 'false' ].each do |boolean|
        result = @parser.parse('true', root: :boolean)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :boolean
      end
    end

    it 'should parse a correct date' do
      result = @parser.parse('1979-05-27T07:32:00Z', root: :date)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :date
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

end
