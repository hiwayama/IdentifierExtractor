# coding: utf-8

# = word-based-totalizer
# Author::Hiromasa IWAYAMA
#
# メソッド単語一覧のJSONを, 単語ベースに集計するスクリプト
#

$:.unshift File.expand_path("../", __FILE__)

require'json'

def word_based_totalize json_fname

  jfile_to_words = open(json_fname) do |f|
    JSON.parse(f.read)
  end

  word_to_jfiles = {}

  jfile_to_words.each do |fname, words|
    normed_words = words.reject{|word|
      word == ""
    }.uniq.compact
    next if normed_words == []

    normed_words.each do |word|
      if word_to_jfiles[word].nil?
        word_to_jfiles[word] = [fname]
      else
        word_to_jfiles[word] << fname
      end
    end
  end

  word_to_jfiles.each do |w, jfile_names|
    jfile_names.sort!
  end
end

if __FILE__ == $0
  require'awesome_print'

  json_fname = ARGV[0].strip
  ap word_based_totalize(json_fname)
end

