require 'spec_helper'
require 'parser'

describe Parser do

  before do
    @parser = Parser.new
  end

  it "should count overlapping triples" do 
    [
      "1/1/2013 12:00:50 AM	Hugo	foo",
      "1/1/2013 12:01:27 AM	Hugo	bar",
      "1/1/2013 12:02:16 AM	Hugo	baz",
      "1/1/2013 12:02:19 AM	Hugo	foo"
    ].each do |line|
      @parser.parse(line)
    end
    @parser.triples["2013-01-01"]["foo > bar > baz"].must_equal 1
    @parser.triples["2013-01-01"]["bar > baz > foo"].must_equal 1
    
  end
    
  it "should separate sessions by user" do
    [
      "1/1/2013 12:00:50 AM	Hugo	foo",
      "1/1/2013 12:01:16 AM	Danyelle	foo",
      "1/1/2013 12:01:27 AM	Hugo	bar",
      "1/1/2013 12:01:37 AM	Hugo	baz",
      "1/1/2013 12:02:19 AM	Danyelle	bar",
      "1/1/2013 12:03:11 AM	Danyelle	baz"
    ].each do |line|
      @parser.parse(line)
    end
    @parser.triples["2013-01-01"]["foo > bar > baz"].must_equal 2
    @parser.triples["2013-01-01"].values.inject{|sum, count| sum + count}.must_equal 2
  end

  it "should separate sessions by a 20 minute interval" do
    [
      "1/1/2013 12:00:50 AM	Hugo	foo",
      "1/1/2013 12:01:27 AM	Hugo	bar",
      "1/1/2013 12:02:16 AM	Hugo	baz",
      "1/1/2013 12:32:19 AM	Hugo	foo",
      "1/1/2013 12:33:11 AM	Hugo	bar",
      "1/1/2013 12:33:37 AM	Hugo	baz"
    ].each do |line|
      @parser.parse(line)
    end
    @parser.triples["2013-01-01"]["foo > bar > baz"].must_equal 2
  end

  it "should raise an exception if line does not contain at least three tab-delimited fields" do
    proc {
      @parser.parse("1/1/2013 12:33:37 AM	Hugo,baz")
    }.must_raise(Parser::LineFormatError)
  end

end

