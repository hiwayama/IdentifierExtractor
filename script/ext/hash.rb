# -*- coding: utf-8 -*-

# = hash.rb
# Author::Hiromasa IWAYAMA
#
# 相対度数分布生成用のHash拡張
#

class Hash
  # 相対度数化 
  def to_relative
    total = self.values.reduce(0.0) do |sum, value|
      sum + value
    end
    raise ZeroDivisionError if total.zero?

    self.each_with_object({}) do |(key, value), new_hash|
      new_hash[key] = value/total
    end
  end

end

