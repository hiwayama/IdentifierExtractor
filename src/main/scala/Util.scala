package main.scala

import scala.io.Source
import main.scala._
import main.scala.element._
import java.io.{File, PrintWriter}
import scala.sys.process._
import scala.util.parsing.json._

object Util extends JavaParser { 
  var map:Map[String, Map[String, Any]] = Map()

  // 指定したファイルを解析して結果をmapに代入
  def parse(filePath:String) {
    
    val source = Source.fromFile(filePath)
    val lines = source.getLines
    val result:List[String] = lines.map{line=>
      val obj = parse(compilationUnit, line)
      obj.get match {
        case Some(o) => 
          o match {
            case obj:Obj => obj.getWord(0)
            case _ =>
          }
        case _ =>
      }
    }.collect{case s:String => s}.toList
    val f = new File(filePath)
    val mapKey = if(map.contains(f.getName)) {
      val substituteFileName = f.getParentFile.getName+"-"+f.getName
      println("duplicate class Name:"+f.getName+" to "+substituteFileName)
      substituteFileName
    } else {
      f.getName
    }
    val elem:Map[String, Any] = Map("words"->result, "path"->f.getAbsolutePath)
    map += (mapKey -> elem)
  }
  
  /**
   * ディレクトリ内のファイルを出力
   */
  def ls(path:String):List[String] = {
    var file = new File(path)
    file.listFiles().map(_.getPath()).toList
  }
  

  /**
   *
   */
  def buildFileList(path:String):List[String] = {
    var file = new File(path)
    file.listFiles().flatMap(file =>
        if(file.isDirectory()){
          println("--"+path+"--")
          buildFileList(file.getPath)
        } else {
          List(file.getPath)
        }
    ).toList
  }

}
