#!/usr/bin/env ruby
require 'date'
require 'json'

# Parse a web log of tab delimeted fields and accumulate
# statistics on consecutive page views within a session
#
# Output: two json files:
#
# 1. counts of triple consecutive page views, organized by date
# 2. dates analyzed, most recent first
#
# Time complexity is O(N)
# One-pass parsing of an N-line logfile, without sorting
#
# The previous one to two page views of each user in
# a session are saved to determine 
# frequency of occurence of a sequence of three
# consecutive page views
#
# Assumption: logfile sessions expire after 20 
# minutes without a page view
class Parser
  class UserTriple 
    attr_accessor :old_page, :prev_page, :prev_timestamp
   
    # Sessions expire after 20 minutes, or 1/72 of a day
    SESSION_THRESHOLD = Rational(1,72) 
    # US date format assumed
    INPUT_DATETIME_FORMAT = "%m/%d/%Y %I:%M:%S %p"

    def initialize(parser)
      @parser = parser
      @old_page, @prev_page, @prev_timestamp = nil, nil, nil
    end

    def log(page, time)
      timestamp = DateTime.strptime(time, INPUT_DATETIME_FORMAT)
    
      if (@prev_timestamp && (timestamp - prev_timestamp <=> SESSION_THRESHOLD) < 0)
        if @old_page # we have a triple in this session
          if (!@parser.triples[_format(timestamp)])
            @parser.triples[_format(timestamp)] = Hash.new(0)
          end
          @parser.triples[_format(timestamp)][[@old_page, @prev_page, page].join(" > ")] += 1
        end
      else
        #reset session
        @prev_page = nil
      end

      @old_page = @prev_page
      @prev_page, @prev_timestamp = page, timestamp 
    end

    def to_s
      "#{@old_page} #{@prev_page} #{@prev_timestamp}"
    end

    private 
      def _format(datetime)
        datetime.strftime("%Y-%m-%d")
      end

  end

  class LineFormatError < StandardError; end

  attr_accessor :triples
  attr_reader :user_data

  def initialize 
    @triples = {} 
    @user_data = {}
  end

  def parse_file(filename)
    @file = File.new(filename, "r")
    @file.each do |line|
      begin
        parse_line(line)
      rescue LineFormatError
        puts "Bad line: #{line}"
      end
    end
    _write_stats
    _write_dates_file
  end

  def parse_line(line)
    timestamp, user, page = line.chomp.split("\t")
    raise LineFormatError if !user || !page
    if !@user_data[user]
      @user_data[user] = UserTriple.new(self)
    end
    @user_data[user].log(page, timestamp)  
  end

  private
    def _write_stats
      file = "stats.json"
      output = File.new(file, "w+") 
      puts "Writing #{file}"
      @triples.each do |date, date_data|
        output.write "var d_#{date.gsub(/-/, "")} = " + JSON.pretty_generate(date_data) + ";"#date_data.sort_by{|key, value| value}.reverse)
      end
    end

    # parsed dates only, most recent first
    def _write_dates_file
      file = "dates.json"
      output = File.new(file, "w+") 
      puts "Writing #{file}"
      output.write "var dates = " + JSON.pretty_generate(@triples.keys.sort.reverse)
    end

end


if ARGV.size != 1 
  puts "Usage: parser logfile"
elsif !File.exist?(ARGV[0])
  puts "Unable to open file #{ARGV[0]}"
else
  Parser.new.parse_file(ARGV[0])
end
    

