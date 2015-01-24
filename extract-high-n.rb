# coding: utf-8

# = (headline)
# Author::Hiromasa IWAYAMA
#
#
#

$:.unshift File.expand_path("../", __FILE__)

require'awesome_print'

fname = "./7lib-hist.csv"

data = []

open(fname) do |f|
  f.each do |line|
    next if line[0]=="#"
    
    tokens = line.strip.split(",")  
    id = tokens[0].to_i
    word = tokens[1].to_s
    values = 7.times.map do |i|
      unless tokens[1+i].nil?
        tokens[2+i].to_f
      else
        0.0
      end
    end
    data << {id: id, word:word, values:values}
  end
end

7.times do |index|
  sorted = data.sort_by{|e| e[:values][index] }.reverse
  puts sorted[0..10].map{|e| e[:word]}.join("\t")
end
