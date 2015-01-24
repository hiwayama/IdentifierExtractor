# IdentifierExtrator

##1. ソースからメソッド一覧(JSONファイル)の生成
    rake run_all  
    rake run_javalib  

##2. JSONファイルから共起度行列の生成
    rake ad_mat  
    rake ad_mat_all  

##3. 共起度行列ファイル(ad_mat.csv)から中心性の計算 ※R使用  
    rake centrality_all  

###3.5. 中心性ファイル(ad_mat.csv.summary.csv)をまとめるには...  
    rake bind_centrality  

##4. 中心性ファイルから変動比を集計して度数分布に変換
    rake total:centrality  

##ライブラリごとの単語出現頻度を集計
    rake total:word_frequency  

