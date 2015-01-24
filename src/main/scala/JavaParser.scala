package main.scala

import main.scala.element._
import scala.util.parsing.combinator._
import scala.collection.immutable.List

/**
 *
 *
 */
class JavaParser extends JavaTokenParsers {

  // ファイル全体
  def compilationUnit = 
    ignoreStatement |
    packageDeclaration |
    typeDeclaration |
    success("") ^^ {case _ => None} // その他の記述を無視

  // 他の記述をクラス名やメソッド名と誤認識しないため
  def ignoreStatement:Parser[None.type] = 
    instanceDeclaration ^^ {case _ => None} |
    ifStatement ^^ {case _ => None}

  // new Hoge()をメソッドと認識する問題の回避
  def instanceDeclaration = "new" ~ ident ~ "("

  def ifStatement =
    "if" ~ "(" |
    "else" ~ "if" ~ "(" |
    "else" ~ "("

  /* 
   * package declaration 
   */
  def packageDeclaration:Parser[Option[String]] =
    "package" ~ packageName <~ ";" ^^ {
      case _ ~ names => Some("--"+names+"--")
    }

  def packageName:Parser[String] = repsep(ident, ".") ^^ {
    case List() => ""
    case names:List[String] => names.reduce(_ +"."+ _)
    case _ => ""
  }

  def typeDeclaration:Parser[Option[Obj]] = 
    classDeclaration ^^ {case c => Some(c)} |
    methodDeclaration ^^ {case m => Some(m)} |
    //constructorDeclaration ^^ {case c => Some(c)} |
    interfaceDeclaration ^^ {case i => Some(i)} 

  /*
   * class declaration
   */
  def classDeclaration:Parser[Class] = opt(classModifiers) ~
    "class" ~> typeName <~ opt(extendExpr) ~ opt(implementsExpr) ~ "{" ^^ {
      case name  => new Class(name)
    }
  
  def implementsExpr = "implements" ~> repsep(typeName, ",")

  def extendExpr = "extends" ~> typeName
  
  def classModifiers:Parser[List[String]] = rep(classModifier)

  def classModifier:Parser[String] =
    "public" | "abstract" | "private" | "final" | "static"

  /*
   * method declaration
   */
  def methodDeclaration:Parser[Method] =
    opt(methodModifiers) ~ typeName ~> ident <~ "(" ^^ {
      case name => new Method(name)
    }

  def methodModifiers = rep(methodModifier)

  def methodModifier = "public" | "protected" | "private" |
    "static" | "abstract" | "final" | "synchronized" | "native"

  /*
   * interface declaration
   */ 
  def interfaceDeclaration:Parser[Interface] = opt(interfaceModifiers) ~ "interface" ~>
    ident <~ "{" ^^ {
      case name => new Interface(name)
    }

  def interfaceModifiers = rep(interfaceModifier)

  def interfaceModifier = "public" | "abstract"

  /*
   * constructor declaration
   */
  def constructorDeclaration:Parser[Constructor] = opt(constructorModifier) ~> ident <~ "(" ^^ {
    case name => new Constructor
  }

  def constructorModifier = "public" | "protected" | "private"

  /*
   * field declaration
   */
  def fieldDeclaration:Parser[List[String]] = 
    opt(fieldModifiers) ~ typeName ~> variableDeclarators

  def fieldModifiers = rep(fieldModifier)
  
  def fieldModifier = 
    "public" | "protected" | "private" | "static" |
    "final" | "transient" | "volatile"

  def variableDeclarators:Parser[List[String]] =
    repsep(variableDeclarator, ",")

  def variableDeclarator:Parser[String] = 
    variableDeclaratorID <~ opt("=")

  def variableDeclaratorID:Parser[String] = ident | ident <~ rep1("[" ~ "]")

  def arguementList = ""

  def typeName:Parser[String] = 
    ident <~ rep1("[" ~ "]") |
    ident <~ opt("<" ~ repsep(ident, ",") ~ ">")

}


