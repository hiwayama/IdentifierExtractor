package main.scala

import scala.io.Source
import main.scala._
import main.scala.element._
import java.io.{File, PrintWriter}
import scala.sys.process._
import play.api.libs.json._

object Main2 extends JavaParser {

  def main(args: Array[String]) {
    val dirNames = Array(
      "/Users/iwayama/Downloads/apache-tomcat-7.0.42-src/java", 
      "/Users/iwayama/Downloads/hadoop-1.2.1/src"
    )

    val jsonFileNames = Array(
      "tomcat-7.0.42.json", 
      "hadoop-1.2.1.json"
    )

    (0 to 1).foreach{i=>
      Util.map = Map()
      Util.buildFileList(dirNames(i)).foreach(path =>
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

      val output = new PrintWriter("json/"+jsonFileNames(i))
      output.println(jsonObj)
      output.close
      
    }
  }
}
