
# JHotDrawの多数のリビジョンの中心性を集計する.
#header=c("v","aveDeg", "sdDeg", "aveClo", "sdClo", "aveBet", "sdBet")
# ジニ係数のライブラリ
disparity_of_centrality<-function(){
  source("http://aoki2.si.gunma-u.ac.jp/R/src/Gini_index.R", encoding="euc-jp")

  result <- data.frame()
  for(v in 362:397) {
    fname="./output/jhotdraw7-r%d.json.ad_mat.csv.summary.csv"
    fname=sprintf(fname, v)
    data<-read.csv(fname,header=F)

    degreeness<-as.vector(t(data["V2"]))
    closeness<-as.vector(t(data["V3"]))
    betweeness<-as.vector(t(data["V4"]))
    md<-mean(degreeness)
    sd<-sd(degreeness)
    mc<-mean(closeness)
    sc<-sd(closeness)
    mb<-mean(betweeness)
    sb<-sd(betweeness)
    geni1<-Gini.index(degreeness)
    geni2<-Gini.index(closeness)
    geni3<-Gini.index(betweeness)
    result <-rbind(result, data.frame(v, md, sd, mc, sc, mb, sb,geni1,geni2,geni3))
  }
  write.table(result ,"jhot362397-centrality.csv", sep=",")
}

