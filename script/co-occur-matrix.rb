# coding: utf-8

# = co-occur-matrix
# Author::Hiromasa IWAYAMA
#
# クラス内で使われている単語一覧のJSONファイルから
# 共起度行列を生成する
#

cdir = File.expand_path("../", __FILE__)
HOME = File.expand_path("~/") 

require'active_support/core_ext/array'
require'json'

require "#{cdir}/ext/array.rb"
require "#{cdir}/../WordIndexer/word-indexer.rb"
require "#{cdir}/dir-distance.rb"

class CoOccurMatrix
 
  def initialize jsonfilename
    json = open(jsonfilename, "r") do |f|
      JSON.parse(f.read)
    end
    
    @data =  json.inject({}) do |h, json_hash|
      filename, data = json_hash
      # メソッド名の重複と空文字を削除
      # 削除によりメソッド一覧が空になったファイルは削除

      return _init_for_old(json) if data.instance_of?(Array)

      words = data["words"]

      method_list = words.reject{|method_name|
        method_name.blank?
      }.uniq
      file_info = {
        words: method_list, 
        path: (data["path"] || ""), 
      } 
      h[filename] = file_info
      h
    end

    # ファイルパスをファイル名に変換.
    @path_list         = {}
    # file名から構成単語を引く
    @methods_in_files = {}

    @data.each do|filename, file_info|
      path  = file_info[:path]
      words = file_info[:words]
 
      key = File.expand_path("../", path).gsub(HOME, "~")
      @path_list[key] ||= []
      @path_list[key] << filename
 
      @methods_in_files[filename] = words 

    end


    # ファイルが所属しているdirのパスを返す
    @path_to_dir_id = {}
    @path_list.each_with_index do |plist, dir_id| 
      dir, fnames = plist
      fnames.each do |fname|
        @path_to_dir_id[fname] = dir_id unless @path_to_dir_id[fname]
      end
    end
  end

  # pathを持たないタイプのJSONファイルでの初期化
  def _init_for_old json_data
    @methods_in_files =  json_data.inject({}) do |h, json_hash|
      filename, words = json_hash
      # メソッド名の重複と空文字を削除
      # 削除によりメソッド一覧が空になったファイルは削除
     
      method_list = words.reject{|method_name|
        method_name.blank?
      }.uniq
      file_info = {
        words: method_list
      } 
      h[filename] = method_list
      h
    end
    self
  end
  
  
  # 単語の出現頻度リストの作成
  def word_hist
    hist = {}
    @methods_in_files.each do |java_filename, method_list|
      method_list.each do |method_name|
        if hist[method_name].nil?
          hist[method_name] = 1
        else
          hist[method_name] += 1
        end
      end 
    end
    hist
  end

  # 単語からその単語を含有するファイル名を返すHashの生成
  def word_based
    word_based_map = {}
    @methods_in_files.each do |filename, words|
      words.each do |word|
        if word_based_map[word].nil?
          word_based_map[word] = [filename]
        elsif !word_based_map[word].member?(filename)
          word_based_map[word] << filename
        end
      end  
    end
    word_based_map
  end

  def sim_mat word_list
    # ノードリスト(単語リスト)の生成
    word_size = word_list.length # 単語数
    w_to_id = {} # 単語 => ID
    word_size.times do |id|
      w_to_id[word_list[id]] = id 
    end

    # 類似度行列の生成(全要素を0で初期化)
    sim_mat = Array.new(word_size).map!{Array.new(word_size, 0)}

    @methods_in_files.each do |filename, words|
      ids = words.map{|w| w_to_id[w] }
      ids.combination(2).map do |id1, id2|
        id1, id2 = [id1, id2].sort
        next if id1==id2
        sim_mat[id1][id2] += 1
      end
    end

    sim_mat
  end

  # 単語をノードとするネットワークの生成
  def word_based_network
    # ノードリスト(単語リスト)の生成
    @word_list = @methods_in_files.values.map{|words|
      words.uniq
    }.flatten.uniq.sort
    word_size = @word_list.length # 単語数
   
    @sim_mat = sim_mat(@word_list)

    # 類似度行列をリンクのリストに変換
    @link_list = []
    word_size.times do |r|
      word_size.times do |c|
        next if r>=c # r<c
        value = @sim_mat[r][c]
        if value > 0
          @link_list << {
            s_id: r, t_id: c, value: value, 
            s_name:@word_list[r], 
            t_name:@word_list[c]
          }
        end
      end
    end
  end

  # ファイルをノードとするネットワークの生成
  def file_based_network

  end

  # Hashの出力
  def export format=nil, filename
    case format
    when :d3
      _export_for_d3 filename
    when :igraph
      _export_for_igraph filename
    else
      # 標準出力に出力
      data =  {word: @word_list, link:@link_list}
      ap data
    end
  end

  # d3.js用のJSONを出力
  def _export_for_d3 filename
    data = {
      nodes: @word_list.each_with_index.map{|w, id|
        {name:w, id:id}
      }, 
      links: @link_list.map{|link|
        {source: link[:s_id], target: link[:t_id], value:link[:value]}
      }
    }

    open(filename, "w") do |f|
      f.puts JSON.generate(data)
    end
  end

  def _export_for_igraph filename
    open(filename, "w") do |f|
      @link_list.each do |link|
        f.puts [link[:s_name], link[:t_name], link[:value]].join(" ") 
      end
    end
  end

  # とりあえず各ノードの接続ノードをデータ化
  def build_tree filename
    word_based_map = word_based
    
    nodes = {}
    word_based_map.values.flatten.uniq.each_with_index do |name, i|
      nodes[name] = {
        id: i, 
        dir_id: @path_to_dir_id[name],
        path: @data[name][:path], 
        id_dist: 0
      }
    end

    links = []
    word_based_map.each do |w, file_names|
      next if file_names.length < 2
      # つながっている2ノードの組み合わせの生成
      file_names.combination(2) do |fname1, fname2|
        fnames = [fname1, fname2]
        # ファイル名をノードのIDに変換
        link = fnames.sort
        links << link
      end

      # nodeに隣接nodeのID情報を追加
      file_names.each do |fname|
        nodes[fname][:neighbor] ||= 
          file_names.reject{|name| fname==name}
      end 
    end
    
    link_data = []
    links.uniq.each{|s, t|
      value = links.select{|l| l[0]==s and l[1]==t}.length
      [s, t].each do |node_id|
        nodes[node_id][:id_dist] += value
      end
      link_data << {
        source: nodes[s][:id], target:nodes[t][:id], value: value,
        s_name: s, t_name: t,  
        path_dir: DirPath.dist(nodes[s][:path], nodes[t][:path])
      }
    }

    # ディレクトリ構造を用いた隣接ノードとの距離の総和を計算
    nodes.keys.each do |name|
      if nodes[name][:neighbor]
        info = nodes[name] 
        neighbors = info[:neighbor].map do |name|
          nodes[name][:path]
        end
        dist = neighbors.reduce(0) do |sum, path|
            sum + DirPath.dist(info[:path], path)
          end
        nodes[name][:dist] = dist / neighbors.length.to_f
      else
        # 隣接nodeがないノードの隣接情報を追記
        nodes[fname][:neighbor] = []
        nodes[fname][:dist] = 0
      end 
    end

    tree = {
      nodes: nodes.map{|name, info|
        id_dist = if info[:neighbor].length>0
                    info[:id_dist]/info[:neighbor].length.to_f
                  else
                    0
                  end
        {
          name:     name, 
          group:    info[:dir_id],
          dist:     info[:dist],
          neighbors: info[:neighbor], 
          id_dist: id_dist 
        }
      }, 
      links: link_data
    }

    # igraph用に出力    
    open(filename, "w") do |f|
      tree[:links].each do |link|
        f.puts [link[:s_name], link[:t_name], link[:value]].join(" ") 
      end
    end

  end
end


if __FILE__ == $0
  [365, 366].each do |v|
    json_path = "./json/jhotdraw7-r%d.json" % v
    com = CoOccurMatrix.new(json_path)

#    word_net = com.word_based_network
#    com.export(:d3, "./output/jht-#{v}-word.json")
#    com.export(:igraph, "./output/jht-#{v}-word.csv")

    com.build_tree("./output/jhot-r#{v}-class.csv")
    com = nil

    # 元ファイル
#    json_old_path = "./jhotdraw7-r%d.old.json" % v
#    com_old = CoOccurMatrix.new(json_old_path)
#    word_net_old = com_old.word_based_network
#    com.export(:d3, "./output/jht-#{v}-old-word.jsom")
#    com_old.export(:igraph, "./output/jht-#{v}-old-word.csv")


  end

end

