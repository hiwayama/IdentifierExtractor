# ベクトルvの大きさ
norm<-function(v) {
  sqrt(sum(v*v))  
}
# 2ベクトル間のコサイン類似度
cossim<-function(v1, v2) {
  sum(v1*v2) / (norm(v1)*norm(v2))
}

# 各ライブラリの単語分布をMDSでプロット
mds_each_libs<-function(){
	# ファイル読み込み
	data<-read.csv("./hist.csv")

	jhot<-as.vector(t(data["jhotdraw.jhotdraw7.r397"]))
	hadoop<-as.vector(t(data["hadoop.1.2.1.core"]))
	tomcat<-as.vector(t(data["tomcat.7.0.42"]))
	swing<-as.vector(t(data["jdk6.swing"]))
	awt<-as.vector(t(data["jdk6.awt"]))
	jetty<-as.vector(t(data["jetty.6.1H8"]))
	storm<-as.vector(t(data["storm.0.9"]))

	# naの置換
	swing<-ifelse(is.na(swing), 0, swing)
	awt<-ifelse(is.na(awt), 0, awt)
	jetty<-ifelse(is.na(jetty), 0, jetty)
	tomcat<-ifelse(is.na(tomcat), 0, tomcat)
	hadoop<-ifelse(is.na(hadoop), 0, hadoop)
	jhot<-ifelse(is.na(jhot), 0, jhot)
	storm<-ifelse(is.na(storm), 0, storm)

	# 距離行列生成
	d<-data.frame(swing,awt,jetty,tomcat,hadoop,jhot,storm)
	labels<-c("swing","awt","jetty","tomcat","hadoop","jhot","storm")
	size<-7
	mat<-matrix(rep(1:size*size), nrow=size,ncol=size)
	for( i in 1:size) {
		for(j in 1:size) {
			mat[i,j] = (1.0-cossim(d[i], d[j]))
		}
	}

	plot(cmdscale(mat), type="n")
	text(cmdscale(mat), labels=labels)

  cmdscale(mat) 
}
