package main.scala.element

object Obj {
  val stopWords = List(
    "get", "set", "main", "is",
    "the", "in", "on", "of", "at", "to", 
    "j" // JFrameなどのJを弾くため.
  )
}

abstract class Obj {
  val wordList:List[String]

  override def toString:String =
    wordList.reduce(_.toString + "," +_.toString)

  def getWord(index:Int):String = {
    val list = wordList.filterNot{w=>
      Obj.stopWords.filter(_ == w).length > 0
    }
    list.applyOrElse(index, (i:Int)=>"")
  }
}

case class Class(name:String) extends Obj {
  val wordList:List[String] = 
    "[A-Z][a-z]*".r.findAllIn(name).map(_.toLowerCase).toList
 

}

case class Method(name:String) extends Obj {
  val wordList:List[String] = 
    "([a-z]|[A-Z])[a-z]*".r.findAllIn(name).map(_.toLowerCase).toList
 
  override def toString:String =
    "\t" + wordList.reduce(_.toString + "," +_.toString) 
    //"\t" + this.getWord(0) +"\t"+ name
}

case class Constructor() extends Obj {
  val wordList:List[String] = List()
}

case class Interface(name:String) extends Obj {
  val wordList:List[String] = 
    "[A-Z][a-z]+".r.findAllIn(name).map(_.toLowerCase).toList
}

case class Field(name:String) extends Obj {
  val wordList:List[String] = 
    "([a-z]|[A-Z])[a-z]*".r.findAllIn(name)
      .map(_.toLowerCase).toList

  override def toString:String =
    "\t" + wordList.reduce(_.toString + "," +_.toString) 
}

