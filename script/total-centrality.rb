# coding: utf-8

# = total-centrality
# Author::Hiromasa IWAYAMA
#
# 中心性の値を度数分布に変換
#

require_relative'./ext/array.rb'
require_relative'./util.rb'

# 各中心性の度数分布化
def to_hist filename, index 
  keys = []
  Util.read_each(filename) do |line|
    next if line.strip[0] == "#"
    tokens = line.strip.split(",")
    next if tokens[index].nil?
    keys << tokens[index].to_f
  end
  
  keys.to_hist do |value|    
    inverse_class_interval_width = 2000 # 階級幅の逆数
    (value * inverse_class_interval_width).to_i / inverse_class_interval_width.to_f
  end
end

# しきい値を超えたかどうかでの集計
def total_by_th hist, threshold
  less_value_count, over_value_count, total = 0, 0, 0
  hist.each do |value, count|
    if value >= threshold
      less_value_count += count
    else
      over_value_count += count
    end
    total += count 
  end
  
  puts "<1 #{less_value_count / total.to_f}"
  puts ">1 #{over_value_count / total.to_f}"

end



require'awesome_print'

# Ct/Ct-1を計算
def ratio_of_centrality ct, ct_1
  word_list = (ct.keys + ct_1.keys ).uniq
 
  ratios = {}
  word_list.each do |w|
    if ct[w] and ct_1[w]
      centralities = [:b, :c, :d].reject{|type|
        ct_1[w][type].zero?
      }.map{|type|
        [ type, ct[w][type]/ct_1[w][type] ]
      }
      ratios[w] = Hash[*centralities.flatten]
    end
  end
  ratios 
end

# 中心性の変動比Ct/Ct-1を計算して集計する
def decreasing_ratio_of_centrality
  # 中心性ファイルの読み込み
  fname = "jhotdraw7-r%d.json.ad_mat.csv.summary.csv"
  centralities = {}
  (362..397).each do |v|
    centralities[v] = {}
    open("./../output/#{fname % v}") do |f|
      f.each do |line|
        w, cd, cc, cb = line.strip.split(",").map(&:strip)
        w.gsub!(%Q("), "")
        centralities[v][w] = { b:cb.to_f, c:cc.to_f, d:cd.to_f }
      end
    end
  end    
  # 変動比の集計
  header = %w(v b>=1 b<1 c>=1 c<1 d>=1 d<1)
  puts "#" + header.join(",")
  (363..397).each do |v|
    ratios = ratio_of_centrality(centralities[v], centralities[v-1])
    counter = { b:[0, 0], c:[0, 0], d:[0, 0] }
    ratios.each do |w, c|
      [:b, :c, :d].each do |type|
        if c[type].nil?
          next
        elsif c[type] >= 1.0
          counter[type][0] += 1
        else
          counter[type][1] += 1
        end
      end   
    end
    [:b, :c, :d].each do |type|
      sum = counter[type].reduce(&:+)
      2.times{|i| counter[type][i] /= sum.to_f}
    end
    puts "#{v},"+ counter.values.flatten.join(",")
  end
end

if __FILE__ == $0

  decreasing_ratio_of_centrality
  
end
