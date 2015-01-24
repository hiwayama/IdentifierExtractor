# coding: utf-8

# = more-matrix
# Author::Hiromasa IWAYAMA
#
# 二次元配列を使った Symbolラベルで値アクセス可能な行列クラス
#

$:.unshift File.expand_path("../", __FILE__)

require'awesome_print'

class Matrix < Array
  
  # -------
  # 行列初期化
  # 
  class << self
    alias _new_ new 
  end
  def self.new labels, val=0
    n = labels.size
    to_i, to_label = self.create_labels labels

    ap to_i
    ap to_label

    puts "hoge"

    mat = self._new_(n).map{ self._new_(n, val)}
    mat.add_labels([to_i, to_label])
    mat
  end

  # -------
  # ラベル周り
  #  
  def self.create_labels labels
    to_i = {}
    to_label = {}
    labels = labels.map(&:to_sym).sort
    labels.each_with_index do |label, i|
      to_i[label] = i
      to_label[i] = label
    end
    [to_i, to_label]
  end
  def add_labels labels
    @to_index, @to_label = labels
  end

  # -------
  # 値取得
  # 
  alias fetch_with_index [] 
  def [] label_i, label_j
    return nil if @to_index[label_i].nil? or @to_index[label_j].nil?
    fetch_with_index(@to_index[label_i], @to_index[label_j])    
  end

  # -------
  #　比較
  # 
  alias _eq_ ==
  def == other
    self._eq_ other and
      @to_index == other.instance_variable_get(:@to_index) and
      @to_label == other.instance_variable_get(:@to_label)
  end

  # --------
  # コレクション操作系
  #
end

# ---------------------------------------
## RSpec
require'rspec'

describe Matrix, "" do
  it "apply with sym label" do
    mat = Matrix.new(["a", "b", "c"])
    mat[:a, :a].should eq 0
    mat[:a, :b].should eq 0
    mat[:a, :c].should eq 0
    mat[:b, :a].should eq 0
    mat[:b, :b].should eq 0
    mat[:b, :c].should eq 0
    mat[:c, :a].should eq 0
    mat[:c, :b].should eq 0
    mat[:c, :c].should eq 0

    mat["a", "a"].should eq nil
    mat["a", "b"].should eq nil
    mat["a", "c"].should eq nil
    mat["b", "a"].should eq nil
    mat["b", "b"].should eq nil
    mat["b", "c"].should eq nil
    mat["c", "a"].should eq nil
    mat["c", "b"].should eq nil
    mat["c", "c"].should eq nil
  end

  it "compare Matrix" do
    mat1 = Matrix.new(["a", "b", "d"])
    mat2 = Matrix.build([:d, :b, :a]){|r, c| 0 }
    mat3 = Matrix.build([:a, :b, :c]){|r, c| 1 }
    mat4 = Matrix.new(["b", "c", "d"]) 
    mat5 = Matrix.new(["a", "b"])   
    (mat1 == mat2).should be true
    (mat1 == mat3).should be false
    (mat2 == mat3).should be false
    (mat2 == mat4).should be false
    (mat2 == mat5).should be false
  end
end
