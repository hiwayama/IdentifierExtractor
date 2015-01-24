# -*- coding: utf-8 -*-

# = array.rb
# Author::Hiromasa IWAYAMA
#
# 二次元配列用のメソッド中心にArray拡張
#

class Array
  # 二次元行列のファイル出力
  # ※CSV形式
  def to_csv filename, &block
    Util.open(filename, "w") do |f|
      mat.map do |cols|
        f.puts cols.map{|value|
          yield(value)
        }.join(",")
      end
    end 
  end

  # 二次元配列の初期化
  def self.init col, row, defalut=0
    matrix = Array.new(col)
    col.times do |i|
      matrix[i] = [0]*row 
    end
    matrix
  end
  
  # 1次元配列のヒストグラム化  
  def to_hist &block
    hist = {}

    self.each do |value|
      key = yield(value)
      if hist[key].nil?
        hist[key] = 1
      else
        hist[key] += 1
      end
    end
    hist
  end

end

