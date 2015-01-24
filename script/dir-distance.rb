# coding: utf-8

# パスからディレクトリ構造の距離を計測
# Author::Hiromasa IWAYAMA
#
#
#

$:.unshift File.expand_path("../", __FILE__)

require'awesome_print'

class DirPath
  # パスの正規化（ディレクトリ名に変換）
  def self.norm path
    path = "/"+path unless path[0]=="/"
    tokens = path.split("/")
    tokens.shift
    tokens.pop
    if tokens == []
      ""
    else
      tokens.join("/")
    end
  end

  # パス間の距離を測定
  def self.dist path1, path2
    norm_path1 = DirPath.norm(path1)
    norm_path2 = DirPath.norm(path2)
    if norm_path1==norm_path2
      0
    else
      tokens = [
        norm_path1.split("/"), 
        norm_path2.split("/")
      ]
      max_depth = tokens.map(&:length).max
      depth = 0; i=0
#      ap tokens
      while(i<=max_depth)
        break unless tokens[0][i] == tokens[1][i]
        depth+=1; i+=1;
      end
#      puts "#{depth} #{i}"
      tokens.map{|t| t.length-i}.reduce(&:+) 
    end
  end
end


# ----------------------------------------
require 'rspec'

describe DirPath, "dist" do
  before do
    @paths = [
      "/", 
      "/a1", 
      "/a/b1", 
      "/a/b2", 
      "/a/b/c1", 
      "/d1", 
      "/d/e1", 
      "/d/e/f1"
    ]
  
    @dists = [
      [0, 0, 1, 1, 2, 0, 1, 2], 
      [0, 0, 1, 1, 2, 0, 1, 2], 
      [1, 1, 0, 0, 1, 1, 2, 3], 
      [1, 1, 0, 0, 1, 1, 2, 3], 
      [2, 2, 1, 1, 0, 2, 3, 4], 
      [0, 0, 1, 1, 2, 0, 1, 2], 
      [1, 1, 2, 2, 3, 1, 0, 1], 
      [2, 2, 3, 3, 4, 2, 1, 0],  
    ]
  end 

  it 'DirPath.norm' do
    DirPath.norm(@paths[0]).should eq ""
    DirPath.norm(@paths[1]).should eq ""
    DirPath.norm(@paths[2]).should eq "a"
    DirPath.norm(@paths[3]).should eq "a"
    DirPath.norm(@paths[4]).should eq "a/b"
    DirPath.norm(@paths[5]).should eq ""
    DirPath.norm(@paths[6]).should eq "d"
    DirPath.norm(@paths[7]).should eq "d/e"
  end

  it 'DirPath.dist' do
    8.times do |i|
      8.times do |j|
#        puts "#{@paths[i]} - #{@paths[j]}"
        DirPath.dist(@paths[i], @paths[j]).should eq @dists[i][j]
      end
    end 
  end

  it 'DirPath.dist' do
    home_dir = "/Users/iwayama/"
    root_dir = home_dir+"/Documents/jhotdraw-svn/jhotdraw7/src/"
    path1 = root_dir + "main/java/net/n3/nanoxml/StdXMLReader.java"
    path2 = root_dir + "main/java/org/jhotdraw/samples/svg/SVGDrawingPanel.java"

    DirPath.dist(path1, path2).should eq 7
  end
end
