# coding: utf-8

# = word-indexer.rb
# Author::Hiromasa IWAYAMA
#
# DBに単語を追加するのと, 文字列のID化
#

cdir = File.expand_path("../", __FILE__)
$:.unshift cdir

require "#{cdir}/config/boot.rb"
require File.expand_path("../script/util.rb", cdir)

module WordIndexer

  # 文字列に対して一意なIDを振る
  # DB上にない文字列の場合はDBに追加し, そのIDを返す
  def self.to_id string
    row = Word.where(word:string).first
    if row.nil?
      Word.create(word:string).id
    else
      row.id
    end
  end

  # IDに対応した文字列を返す
  # ない場合は-1を...
  def self.to_word id
    row = Word.where(id: id).first
    unless row.nil?
      row.word
    else
      -1 
    end
  end
end

