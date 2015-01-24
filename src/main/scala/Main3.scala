package main.scala

import scala.io.Source
import main.scala._
import main.scala.element._
import java.io.{File, PrintWriter}
import scala.sys.process._
import play.api.libs.json._

/**
 * 指定したディレクトリ以下のjavaファイルを解析し, JSON化して出力
 */
object Main3 extends JavaParser {

  def main(args: Array[String]) {
    val dirName = "/Users/iwayama/Downloads/storm/storm-core/src/"

    val jsonFileName = "output.json"
    Util.buildFileList(dirName).foreach(path =>
      if(path.endsWith(".java")) {
        Util.parse(path)
      }
    )
    
    val jsonObj:JsObject = new JsObject(Util.map.toSeq.map{ outer =>
      ( outer._1, new JsObject(outer._2.toSeq.map{ inner =>
        ( 
          inner._1,
          inner._2 match {
            case arr:List[String] => new JsArray(arr.toSeq.map{s => new JsString(s)})
            case s:String => new JsString(s)
          }
        )
      }) )
    })

    val output = new PrintWriter("json/"+jsonFileName)
    output.println(jsonObj)
    output.close
    
  }
}
