require_relative 'spec_helper'


describe TOMLParser do

  before :all do
    @parser = TOMLParser.new
  end

  describe "string" do
    it 'should parse a correct string' do
      result = @parser.parse('"This is a string"', root: :string)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :string
    end
  end

  describe "float" do
    it 'should parse a correct float' do
      ['-0.0', '1.4', '123.2', '+1.1', '+123.9' ].each do |float|
        result = @parser.parse(float, root: :float)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :float
      end
    end
  end

  describe "integer" do
    it 'should parse a correct integers' do
      ['-1', '1', '123', '+1', '+123' ].each do |integer|
        result = @parser.parse(integer, root: :integer)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :integer
      end
    end
  end

  describe "boolean" do
    it 'should parse a correct boolean' do
      ['true', 'false' ].each do |boolean|
        result = @parser.parse('true', root: :boolean)
        result.should_not be_nil
        result.should respond_to(:type)
        result.type.should eql :boolean
      end
    end
  end

  describe "date" do
    it 'should parse a correct date' do
      result = @parser.parse('1979-05-27T07:32:00Z', root: :date)
      result.should_not be_nil
      result.should respond_to(:type)
      result.type.should eql :date
    end
  end

end
