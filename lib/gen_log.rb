#!/usr/bin/env ruby
#
# Generate some test data
#
require 'Date'

SIZE = 100000
USERS = %w( Jannette Kiana Cary Tyree Harriet Hugo Randal Osvaldo Joeann Katina Minna Tammie Tajuana Bobbye Tami Carina Penni Shanon Maritza Deloras Magda Ai Ashly Francina Janyce Hassie Maya Dorethea Danyelle Chante Tobie Curt Genny Dodie Tandra Sunshine Maegan Zetta Marcie Wilma Verdell Bertram Ervin Candelaria Jule Shauna Clinton Laronda Kimberlie Vasiliki )


# provide some click-through trends
class Session
  attr_reader :page
  
  def initialize
    login
  end

  def click
    if rand(7) == 0
      logout
    else
      @page =
        case @page
        when "foo.html" then %w(bar.html baz.html hoopydoopy.html hoopydoopy.html hoopydoopy.html).sample
        when "bar.html" then %w(foo.html baz.html hoopydoopy.html hoopydoopy.html hoopydoopy.html).sample
        when "baz.html" then %w(foo.html bar.html hoopydoopy.html).sample
        when "hoopydoopy.html" then %w(bar.html baz.html).sample
        end
    end
  end

  def login
    @page = %w(foo.html foo.html foo.html foo.html bar.html bar.html bar.html).sample
  end

  def logout
    @page = nil
  end
end

#initialize sessions
sessions = Hash.new
USERS.each do |user|
  sessions[user] = Session.new
end

datetime = DateTime.new(2013, 1, 1)
sec = 0
file = File.new("web.log", "w+")

# every few seconds someone clicks or possibly logs in
(1..SIZE).each do |i|
  datetime += rand(60)/(24.0 * 60.0 * 60.0)

  user = USERS.sample
  session = sessions[user]

  if session.page
    if (rand(1000) == 0) 
      file.puts "This is a bad line"
    end
    file.puts "#{datetime.strftime("%-m/%-d/%Y %-I:%M:%S %p")}\t#{user}\t#{session.page}"
    session.click
  else
    if (rand(30) == 0)
      # user logging back in
      sessions[user].login
    end
  end
end




