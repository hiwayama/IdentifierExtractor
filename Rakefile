# coding: utf-8

CURRENT_DIR = File.expand_path("../", __FILE__)


$:.unshift CURRENT_DIR
$:.unshift CURRENT_DIR+"/script"


require'active_support/core_ext/object/try'
require'awesome_print'

namespace :total do 
  task :centrality do
  desc '中心性の値を集計して度数分布に変換'
    require"total-centrality.rb"

    # 元ファイルの列番号と名称の対応表
    label_to_indexes = {
      degree:       3,
      closeness:    4, 
      betweenness:  5
    }
    filename = "#{CURRENT_DIR}/script/other/365366-centrality-ratio.csv"

    label_to_indexes.each do |label, i|
      hist = to_hist(filename, i)
      puts "--#{label}--"
      total_by_th(hist, 1.0)
      puts hist.to_s
    end
  end

  task :word_frequency do
  desc '各ライブラリでの単語の出現頻度を単語別に集計'
    require"#{SCRIPTS_DIR}/co-occur-matrix.rb"
    require"#{SCRIPTS_DIR}/ext/hash.rb"

    # 対象ファイル名
    attrs = [
      "jhotdraw/jhotdraw7-r397", 
      "hadoop-1.2.1-core", 
      "tomcat-7.0.42", 
      "jdk6-swing", 
      "jdk6-awt", 
      "jetty-6.1H8",
      "storm.0.9"
    ]
    jsonfile_path = "#{CURRENT_DIR}/json/%s.json"

    hists = []
    attrs.each do |attr|
      fname = jsonfile_path % attr 
      com = CoOccurMatrix.new(fname)
      com.word_hist.to_relative.each do |w, freq|
        id = WordIndexer.to_id(w)
        if hists[id].nil?
          hists[id] = {word: w}
        end
        hists[id][attr] = freq
      end
    end

    header = ["ID", "word", attrs].flatten.join(",")
    puts "#" + header
    hists.each_with_index do |elem, i|
      next if elem.nil?
      freqs = attrs.map{|attr| elem[attr]}.map do |value|
        value.nil? ? "" : value
      end

      puts [i, elem[:word], freqs].flatten.join(",")
    end
  end
end

namespace :plot do
  task :network do |t|
    # TODO rake ad_matの生成物から共起ネットワークの描画
    raise NotImplementedError
  end

  task :mds do |t|
    # TODO MDSの描画
    # script/generate-MDS.Rを使えば...！
    raise NotImplementedError
  end
end

task :centrality do |t|
desc 'Rでの中心性の計算'
  require'rsruby'

  # 入力 rake ad_mat(共起度リスト)
  target = ENV['target'].try(:strip)
  if target.nil?
    puts "rake main target='target file path'"
    exit
  end

  r = RSRuby::instance
  r.eval_R(<<-RCOMMAND)
    source("./script/mds.R")
    generate.graph.summary("#{File.expand_path(target)}")
  RCOMMAND
end

task :centrality_all do |t|
desc 'rake centralityをoutput/内のすべてのad_mat.csvに適用'
  Dir.glob(CURRENT_DIR+"/output/*.json.ad_mat.csv") do |path|
    `rake centrality target=#{path}`
  end
end

task :bind_centrality do |t|
desc 'rake centralityで生成したsummaryファイルをまとめる'
  cd "#{HOME}/script" do 
    `ruby bind-file.rb`
  end
end

task :ad_mat do |t|
desc 'JSONファイルから共起度行列を生成し出力'
  
  require"co-occur-matrix.rb"
  require"WordIndexer/word-indexer.rb"

  jsonfile_path = ENV['jsonfile_path'].try(:strip)
  if jsonfile_path.nil?
    $stderr.puts "rake ad_mat jsonfile_path='jsonfile_path...'"
    exit
  else  
    filename = File.basename(jsonfile_path)
  end

  # 共起度行列の生成
  com = CoOccurMatrix.new(jsonfile_path) 

  open("#{CURRENT_DIR}/output/#{filename}.ad_mat.csv", "w") do |f|
    com.to_list.each do |edges|
      f.puts edges.values.join(",")
    end
  end
end

task :ad_mat_all do |t|
desc 'json/以下のすべてのjsonファイルにrake ad_matを行う'
  target_dir = ENV['target_dir'].try(:strip)
  dir = nil
  if target_dir.nil?
    $stderr.puts "rake ad_mat_all target_dir=[DIRECTORY PATH]"
    exit
  else  
    dir = File.expand_path(target_dir, CURRENT_DIR)
  end

  Dir.glob("#{dir}/*.json") do |path|
    puts path
    `rake ad_mat jsonfile_path=#{path}`
  end
end


task :run do |t|
desc 'ソースからJSONファイルの生成'
 
  version = 365
  HOME = File.expand_path("~")
  cd("#{HOME}/Documents/jhotdraw-svn") do
    puts "r#{version}"
    system("svn update -r #{version}")
    system("rm -rf /src/main/java/org/samples")
  end
  system("sbt 'run '#{version}")

end

task :run_all do |t|
desc 'jHotDrawの各リビジョンのjson生成'
  puts "エラー"
  exit
  # 実行してもsvnのリビジョン変更と, sbtのプログラムが実行できない...

  HOME = File.expand_path("~")
  (362..397).each do |v|
    puts "r#{v}"

    # ソースのリビジョン変更
    cd("#{HOME}/Documents/jhotdraw-svn") do
      `svn update -r #{v}`
    end

    # sbt実行 
    `sbt 'run-main Main '#{v}`
    # 出力されたJSONファイルの整形
    `vim -c \":%s/\], /\],/g\" -c wq json/jhotdraw7-r#{v}.json`
  end
end

task :run_javalib do |t|
desc '3ライブラリ比較の為のJSON生成'
  `sbt 'run-main Main2'`

  `vim -c \":%s/\], /\],/g\" -c wq json/tomcat-7.0.42.json`
  `vim -c \":%s/\], /\],/g\" -c wq json/hadoop-1.2.1-core.json`
end

namespace :javafile do
  require"util.rb"

  task :utf8 do |t|
  desc "指定ディレクトリのjavaファイルをすべてUTF8化"
    dir = ENV['target'].strip 
    Util.recursive_search(File.expand_path("./", dir)) do |path|
      if File.extname(path) == ".java"
        `nkf -w --overwrite #{path}` rescue puts $@ 
      end
    end
  end

  task :count do |t| 
  desc "指定ディレクトリ以下のjavaファイルの数を数えて出力"
    count = 0
    dir = ENV['target'].strip
    Util.recursive_search(File.expand_path("./", dir)) do |path|
      count+=1 if File.extname(path) == ".java"
    end 
    puts "java file: #{count}" 
  end

end

task :reachability do |t|
  $:.unshift "#{CURRENT_DIR}/grapy/lib"
  require'grapy'
  

  group_ids = []
  data = Grapy::Data.load("./output/jhotdraw7-r365.json.ad_mat.csv") 
  g =  Grapy.count_group(data.array)
  g.each_with_index do |id, i|
    unless data.label_list[i].nil?
      puts "#{data.label_list[i]} #{id}"
      group_ids << id
    end
  end
  puts group_ids.uniq.length

  puts "---"
#  data = Grapy::Data.load("./output/jhotdraw7-r366.json.ad_mat.csv") 
#  g = Grapy.count_group(data.array)
#  puts g.to_s
end

