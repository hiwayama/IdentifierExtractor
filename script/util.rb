# coding: utf-8

# = util.rb
# Author::Hiromasa IWAYAMA
#
# Util集
#

module Util

  # 指定ディレクトリ以下を探索
  # + Param:: dir 対象ディレクトリ
  # + Param:: block 各ファイルに対しての処理内容
  def self.recursive_search dir, &block
    Dir::entries(dir).each do |name|
      next if name[0] == "."
      abs_name = dir+"/"+name
      if File::ftype(abs_name).strip == "directory"
        recursive_search(abs_name, &block)
      else
        yield(abs_name)
      end
    end
  end
     
  # 複数ファイルをまとめて読み込む
  def read_files output_dir, filename_regex, &block
    Dir::glob("#{output_dir}/#{filename_regex}") do |fname|
      File.open(fname, "r") do |f|
        yield(f)
      end
    end
  end

  # ファイルを一行ずつ読み出す際のローンパターン
  def self.read_each filename, &block
    File.open(filename, "r") do |f|
      f.each do |line|
        yield(line)
      end
    end
  end

end


