require_relative 'spec_helper'

describe Ptolemy do
  it 'should be able to parse' do
    Ptolemy::parse('"hello world"')
  end
end
