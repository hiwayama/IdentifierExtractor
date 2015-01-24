# MDSの２次元プロット
plot.mds<-function(filename) {
  data<-read.table(filename,header=F, sep=",")
  size<-max(data[["V3"]]) 
  # 隣接行列の生成
  mat <- matrix(rep(0,size*size),nrow=size,ncol=size)
  for( index in 1:length(data[["V1"]]) ) {

	  cost <- data[["V1"]][index]
	  r <- data[["V2"]][index]
	  c <- data[["V3"]][index]
	
	  mat[r,c] <- cost#1.0/(cost+1.0)
	  mat[c,r] <- cost#1.0/(cost+1.0)
  }
  return(mat)
  # ラベル用文字列の生成
  labels = rep("", size)
  for( index in 1:length(data[["V1"]]) ) {
    index1 <- data[["V2"]][index]
    index2 <- data[["V3"]][index]
    str1 <- as.character(data[["V4"]][index])
    str2 <- as.character(data[["V5"]][index])
    labels[index1] <- str1
    labels[index2] <- str2	
  }
  # プロット（pngでの出力）
  png(paste(filename, ".png", sep=""))
  plot(cmdscale(mat), type="n", xlab="", ylab="")
  text(cmdscale(mat),labels=labels)
  dev.off()

  # MDSの結果をCSVとして出力
  write.table(
    data.frame(word_list, mds[,1], mds[,2]), 
    paste(filename, "-mds.csv", sep=""), 
    sep=",", 
    col.names=FALSE, row.names=FALSE
  )
}

# 共起ネットワーク図の生成とeps出力
#plot.network<-function(filename) {
#  library("igraph")
#  th<-5
#  data.origin<-read.table(filename)
#  data<-subset(data.origin,  V1>th)
#  g<-graph.data.frame(data[4:5],  directed=F)
#  E(g)$weight<-sapply(data[[1]],  function(v){ v/(v+1.0) })
#  
#  postscript(paste(filename, "-th", th, "-network.eps", sep=""),  family="serif")
#  plot(g,  vertex.size=1,  layout=layout.lgl)
#  dev.off()
#}


# 共起表現の頻度分布からグラフ指標の計算
generate.graph.summary<-function(filename) {
  library("igraph")
  data<-read.table(filename, sep=" ")
  g<-graph.data.frame(data[1:2], directed=F)
  # 距離として共起度の逆数をとる
  E(g)$weight <- sapply(data[[3]], function(v){ v/(v+1.0) })
#  E(g)$weight <- sapply(data[[3]], function(v){ v })

  output_filename = paste(filename, ".summary.csv", sep="")
  write.table(
    data.frame(V(g)$name, 
      degree(g)/length(V(g)), 
      ( length(V(g)) -1 ) / apply(shortest.paths(g), 1, sum),
      betweenness(g)
    ),
      output_filename,
      sep=",", row.names=FALSE, col.names=FALSE
  )
  return(g);
}

