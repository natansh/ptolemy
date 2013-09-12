# encoding: UTF-8

require_relative 'spec_helper'

describe Ptolemy::Parser do

  describe "#parse" do
    describe 'Valid TOML input' do
      it 'should parse TOML specification file' do
        filename = 'example.toml'
        path = File.expand_path(File.join(File.dirname(__FILE__), filename))
        result = Ptolemy.parse_file(path)

        result['title'].should eql('TOML Example')

        owner = result['owner']
        owner.should be_a_kind_of(Hash)
        owner.should eql({
          'name' => 'Tom Preston-Werner',
          'organization' => 'GitHub',
          'bio' => "GitHub Cofounder & CEO\nLikes tater tots and beer.",
          # Test for Dates
          'dob' => DateTime.parse('1979-05-27T07:32:00Z')
        })

        database = result['database']
        database.should be_a_kind_of(Hash)
        database['ports'].should be_a_kind_of(Array)
        database.should eql({
          'server' => "192.168.1.1",
          'ports' => [ 8001, 8001, 8002 ],
          'connection_max' => 5000,
          'enabled' => true
        })

        servers = result['servers']
        servers.should be_a_kind_of(Hash)
        servers.keys.sort!.should eql ['alpha', 'beta']

        alpha = servers['alpha']
        alpha.should be_a_kind_of(Hash)

        beta = servers['beta']
        beta.should be_a_kind_of(Hash)

        clients = result['clients']
        clients['data'].should eql([["gamma", "delta"], [1, 2]])

        hosts = clients['hosts']
        hosts.should eql(["alpha", "omega"])
      end

      it 'should parse hard TOML example file' do
        filename = 'hard_example.toml'
        path = File.expand_path(File.join(File.dirname(__FILE__), filename))
        result = Ptolemy.parse_file(path)

        the = result['the']
        the.should be_a_kind_of(Hash)
        the['test_string'].should eql("You'll hate me after this - #")
        hard = the['hard']
        hard['test_array'].should eql(["] ", " # "])
        hard['test_array2'].should eql([ "Test #11 ]proved that",
                                        "Experiment #9 was a success" ])
        hard['another_test_string'].should eql(" Same thing, but with a string #")
        hard['harder_test_string'].should eql(
          " And when \"'s are in the string, along with # \"")

        bit = hard['bit#']
        bit.should be_a_kind_of(Hash)
        bit['what?'].should eql("You don't think some user won't do that?")
        bit['multi_line_array'].should eql([ "]"])
      end
    end

    describe 'Invalid TOML input' do
      it 'should give error if anything other than tabs/space/nl/comment'\
        'is present after key group on line' do
        input = "[error]   if you didn't catch this, your parser is broken"
        expect{Ptolemy.parse(input)}.to raise_error(Ptolemy::ParseError)
      end

      it 'should give error if anything other than tabs/space/nl/comment'\
        'is present after key value pair on line' do
        input = 'string = "Hello World!" Have fun'
        expect{Ptolemy.parse(input)}.to raise_error(Ptolemy::ParseError)
        input = "number = 3.14  pi <--again forgot the #"
        expect{Ptolemy.parse(input)}.to raise_error(Ptolemy::ParseError)
      end

      it 'should give an error for a malformed multiline array' do
        input = <<END
array = [
         "This might most likely happen in multiline arrays",
         Like here,
         "or here,
         and here"
]     End of array comment, forgot the #
END
        expect{Ptolemy.parse(input)}.to raise_error(Ptolemy::ParseError)
      end
    end

    describe 'Encoding' do
      it 'should give an error if input is not UTF-8 encoded' do
        input = 'hello = "world"'
        input.encode!(Encoding::ASCII)
        input.encoding.name.should eql('US-ASCII')
        expect{Ptolemy.parse(input)}.to \
          raise_error(Ptolemy::ParseError, "Input is not UTF-8 encoded")
      end

      it 'should give an error if input has invalid byte sequence' do
        input = "hello = 'hi \255'"
        input.encoding.name.should eql('UTF-8')
        expect{Ptolemy.parse(input)}.to \
          raise_error(Ptolemy::ParseError, "Input contains invalid UTF-8 byte sequence")
      end
    end
  end

end
