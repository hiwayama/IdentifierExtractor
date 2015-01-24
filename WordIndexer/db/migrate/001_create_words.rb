# -*- coding: utf-8 -*-

# = (headline)
# Author::Hiromasa IWAYAMA
#
#
#

$:.unshift File.dirname(__FILE__)

class CreateWords < ActiveRecord::Migration

  def self.up
    create_table :words do |t|
      t.string :word
      t.timestamps
    end

    add_index(:words, :word, :unique=>true)
  end

  def self.down
    drop_table :words
  end
end

