package main.scala

import scala.util.parsing.combinator._
import scala.collection.immutable.List

import main.scala.element._

/**
 *
 *
 */
class JavaMiniParser extends JavaTokenParsers {

  // ファイル全体
  def compilationUnit =
    rep(comments) ~
    opt(packageDeclaration) ~>
    rep(comments) ~
    typeDeclaration ^^ {
      case _ ~ td => td
    }

  def typeDeclaration = 
    classDeclaration | interfaceDeclaration
 
  /**
   * comment
   */
  def comments:Parser[None.type] =
    singleComment ^^ {case _ => None} |
    multiComment  ^^ {case _ => None}
    
  def singleComment = "//" ~> ".*\n".r

  def multiComment = 
    "/*" ~> """(?ms)((?!\*/).*)\*/""".r

  /**
   * Package Declaration
   */
  def packageDeclaration = 
    "package" ~> packageName <~ ";"

  def packageName:Parser[String] = repsep(ident, ".") ^^ {
    case List() => ""
    case names:List[String] => names.reduce(_+"."+_)
    case _ => "" 
  }

  /*
   * class declaration
   */
  def classDeclaration:Parser[Map[String, List[Any]]] =
    opt(classModifiers) ~
    "class" ~> typeName ~ opt(extendExpr) ~
    opt(implementsExpr) ~ classBody ^^ {
      case name ~ _ ~ _ ~ b => Map(name -> b)
    }
  
  def implementsExpr:Parser[List[String]] =
    "implements" ~> repsep(typeName, ",")

  def extendExpr:Parser[String] =
    "extends" ~> typeName
  
  def classModifiers:Parser[List[String]] =
    rep(classModifier)

  def classModifier:Parser[String] =
    "public" | "abstract" | "private" | "final" | "static"

  def classBody:Parser[List[Any]] = 
    "{" ~> rep(classElement) <~ "}" ^^ {
      case l:List[Any] => l.filterNot(_ == None) 
    }

  def classElement:Parser[Any] = 
    comments |
    methodDeclaration ^^ {
      case name=> new Method(name)
    } |
    fieldDeclaration ^^ {
      case names => names.map{name => new Field(name)}
    } |
    classDeclaration

  /*
   * interface declaration
   */
  def interfaceDeclaration = opt(interfaceModifiers) ~ "interface" ~
    typeName ~ opt(extendInterfaceExpr) ~ interfaceBody

  def interfaceModifiers = rep1(interfaceModifier)

  def interfaceModifier:Parser[String] = "public" | "abstract"

  def extendInterfaceExpr = "extends" ~> rep1sep(typeName, ",")

  def interfaceBody:Parser[List[Any]] =
    "{" ~> rep(interfaceElement) <~ "}"

  def interfaceElement =
    comments |
    methodDeclaration ^^ {
      case name => new Method(name)
    } |
    fieldDeclaration ^^ {
      case names => names.map{name=> new Field(name)}
    }


  /*
   * method declaration
   */
  def methodDeclaration:Parser[String] = 
    opt(methodModifiers) ~ typeName ~>
    ident <~ "(" ~ arguementList ~ ")" ~ methodBody 

  def methodModifiers:Parser[List[String]] = rep1(methodModifier)

  def methodModifier:Parser[String] =
    "public" | "protected" | "private" | "static" |
    "abstract" | "final" | "synchronized" | "native"

  def methodBody:Parser[None.type] = "{" ~> rep(methodStatement) <~ "}" ^^ {
    case _ => None
  }

  def methodStatement:Parser[Int] = """.*;""".r ^^ {case _ => 1}

  /**
   * field declaration
   */
  def fieldDeclaration:Parser[List[String]] = opt(fieldModifiers) ~ 
    typeName ~> variableDeclarators <~ ";"

  def fieldModifiers:Parser[List[String]] = rep1(fieldModifier)

  def fieldModifier:Parser[String] =
    "public" | "protected" | "private" | "static" |
    "final" | "transient" | "volatile"

  def variableDeclarators:Parser[List[String]] = 
    rep1sep(variableDeclarator, ",")
  
  def variableDeclarator:Parser[String] =
    ident <~ "=" ~ variableInitializer | 
    ident

  def variableInitializer:Parser[String] = """[^=,;]+""".r 

  def arguementList:Parser[List[String]] = repsep(typeName ~> ident, ",")

  def typeName:Parser[String] = 
    ident |
    ident <~ rep1("[" ~ "]") |
    ident <~ "<" ~ repsep(typeName, ",") ~ ">"

}


