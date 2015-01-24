package main.scala

import scala.io.Source
import main.scala._
import main.scala.element._
import java.io.{File, PrintWriter}
import scala.sys.process._
import play.api.libs.json._

/**
 * JHotDrawの各バージョンを解析するMain
 */
object Main extends JavaParser {

  def main(args: Array[String]) {
    val dirName = "/Users/iwayama/Documents/jhotdraw-svn/jhotdraw7/src/main"

    val rNum = args.headOption.getOrElse("-1")
    println("--"+rNum+"--")
    val jsonFileName = "jhotdraw7-r"+rNum+".json"
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
