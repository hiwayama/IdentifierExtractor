# ネットワークの生成スクリプト
# サンプルのクラス図から描画
library("igraph")

file_name="./sample-edge-list.txt"
data<-read.table(file_name)
g<-graph.data.frame(data, directed=F)
E(g)[1:6]$color<-"red"
E(g)[7:18]$color<-"green"
E(g)[19:24]$color<-rep("blue", 6)
E(g)[2]$color<-"black"
V(g)$name<-""
postscript("sample.eps", horizontal=FALSE)
plot(g, vertex.size=1, layout=layout.auto)
dev.off()

file_name="./sample-edge-list-included-get.txt"
data<-read.table(file_name)
g<-graph.data.frame(data, directed=F)
E(g)[1]$color<-"red"
E(g)[2:16]$color<-rep("blue",15)
V(g)$name<-""
postscript("sample-included-get.eps", horizontal=FALSE)
plot(g, vertex.size=1, layout=layout.auto)
dev.off()
