# -*- coding: utf-8 -*-

# = bind-file.rb
# Author::Hiromasa IWAYAMA
#
#
#

cdir = File.expand_path("../", __FILE__)
$:.unshift cdir

require'awesome_print'
require "#{cdir}/util.rb"

# Rの出力結果（igraphでのグラフ指標出力結果）をまとめる.
# id, 文字列,  次数/ノード数 , closeness, betweenness形式


def parse_csv file_path, &block
  data = {}
  open(file_path) do |f|
    f.each do |line|
      tokens = line.strip.split(",")
      yield(data, tokens)
    end
  end
  data
end

class NilClass
  def zero?
    true
  end
end

def centrality_ratio file1_path, file2_path
  d1, d2 = [file1_path, file2_path].map do |path|
    parse_csv(path) do |data, tokens|
      word = tokens[0].strip.gsub("\"", "")
      cd, cc, cb = tokens[1..3].map(&:to_f)
      data[word] = {cd: cd, cc: cc, cb: cb}
    end
  end

  data = {}
  (d1.keys & d2.keys).each do |word|
    ratios = {}
    d1_cent = d1[word]
    d2_cent = d2[word]
    [:cd, :cc, :cb].each do |attr|
      # 二つのうち一つでも0なら計算しない
      unless d1_cent[attr].zero? or d2_cent[attr].zero?
        ratios[attr] = d2_cent[attr]/d1_cent[attr]
      end
    end
    data[word] = ratios
  end
  data
end


# 平均値と中央値を計算
def summary values
  size = values.size
  avg =  values.inject(0.0){|s, v| s+=v}/size
  median = values.sort[size/2] # 簡易
  {avg:avg, med:median}.merge(compare(values))
end

# 出力
def output data
  [:cd, :cc, :cb].each do |attr|
    values = data.map{|word, ratios|
      if !ratios.nil? and !ratios[attr].nil?
        ratios[attr]
      end
    }.compact
    puts "--#{attr}--"
    ap summary(values)
  end
end

def csv data, fname
  open(fname, "w") do |f|
    header =  "# word, cd, cc, cb"
    f.puts header
    data.each do |word, ratios|
      f.puts [word, ratios[:cd], ratios[:cc], ratios[:cb]].join(",")
    end 
  end
end

def compare values
  pots = {low:0, high:0} 
  th = 1.0
  values.each do |v|
    if v>th
      pots[:high] += 1
    elsif v<th
      pots[:low] += 1
    end
  end
  pots
end

if __FILE__ == $0
  file_path_tmpl = "./output/jht-%s-word.csv.summary.csv"
  
  puts "-----------old"
  d = centrality_ratio(
    file_path_tmpl % "365-old", 
    file_path_tmpl % "366-old"                  
  )
  output(d)
  csv(d, "./output/old-365366-ratio.csv")
  
  puts "-----------new"
  d = centrality_ratio(
    file_path_tmpl % "365", 
    file_path_tmpl % "366"                  
  )
  output(d)
  csv(d, "./output/new-365366-ratio.csv")
end
