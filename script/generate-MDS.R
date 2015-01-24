# ------------------------ #
# RでのMDS図生成スクリプト
#
# ------------------------ #

data<-read.table("./output/jhotdraw7-r362.json.histlist.txt") 

# 隣接行列の生成
mat <- matrix(rep(0,516*516),nrow=516,ncol=516)
for( index in 1:length(data[["V1"]]) ) {

	cost <- data[["V1"]][index]
	r <- data[["V2"]][index]
	c <- data[["V3"]][index]
	
	mat[r,c] <- 1.0/(cost+1.0)
	mat[c,r] <- 1.0/(cost+1.0)
}

# ラベル用文字列の生成
labels = rep("", 516)
for( index in 1:length(data[["V1"]]) ) {
	index1 <- data[["V2"]][index]
	index2 <- data[["V3"]][index]
	str1 <- as.character(data[["V4"]][index])
	str2 <- as.character(data[["V5"]][index])
	labels[index1] <- str1
	labels[index2] <- str2	
}
# プロット
plot(cmdscale(mat), type="n", xlab="", ylab="",
	xlim=c(-0.2,0.3), ylim=c(-0.2,0.25))
text(cmdscale(mat),labels=labels)
