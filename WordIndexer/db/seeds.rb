# -*- coding: utf-8 -*-

# = (headline)
# Author::Hiromasa IWAYAMA
#
#
#

$:.unshift File.dirname(__FILE__)

puts File.expand_path("../../", __FILE__)

require_relative File.expand_path("../../", __FILE__) + "/config/boot.rb"

Word.create({word:"hoge"})

