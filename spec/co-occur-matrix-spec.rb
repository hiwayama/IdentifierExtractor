# coding: utf-8

# = (headline)
# Author::Hiromasa IWAYAMA
#
#
#

$:.unshift File.expand_path("../", __FILE__)

require_relative'../script/co-occur-matrix.rb'
require'rspec'

describe CoOccurMatrix do 
  it 'test data' do
    com = CoOccurMatrix.new("spec/test.json")

    com.word_based_network
    com.export(:igraph, "test-network.csv")
  end
end
