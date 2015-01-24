
import org.scalatest.FunSuite
import main.scala._
import main.scala.element._

/**
 * test
 *
 *
 */
class JavaMiniParserSuite extends FunSuite {

  val p = new JavaMiniParser

  test("with comment") {
    val src = """
    public class Hoge {
      // int i
      private static final int i = 1; // iii

      public int hoge, fuga; // hogefuga

      /* hoge */
      /** 
       * aaa
       */
      public void hoge() {
        int i = 3;
        int j = 4*i;
        double k = fuga(i);
        Sytem.out.println(i+" "+j);
      }
    }
    """
      
    val result = p.parse(p.compilationUnit, src).get
    println(result)
    
    val comments = """
      // hogefuga

    """

    assert(p.parse(p.comments, comments).get == None)

    val multiComments = "/** dabadaba * * */"
    assert(p.parse(p.comments, multiComments).get == None)
    
    val multiComments2 = """
      /* 
       * hogefuga
       * aaa
       */
    """
    assert(p.parse(p.comments, multiComments2).get == None)
  }

  test("typeName") {
    assert(p.parse(p.typeName, "String").get == "String")
    assert(p.parse(p.typeName, "String[]").get ==
      "String")
    assert(p.parse(p.typeName, "String[][]").get == 
      "String")
    assert(p.parse(p.typeName, "List<String>").get ==
      "List")
    assert(p.parse(p.typeName, "Map<String, List<String>>").get ==
      "Map")
  }

  test("method declaration") {
   
    assert(p.parse(p.methodBody, "{}").get == None)
    assert(p.parse(p.methodBody, "{ }").get == None)
    assert(p.parse(p.methodBody, 
      """{ 
      }""").get == None)
   
    // TODO []や<>をつけるとmethoddeclarationがこける...
    //println(p.parse(p.methodDeclaration, "List[] getHoge(){}").get)

    assert(
      p.parse(p.methodDeclaration, 
      """public String getRequiredVersions(){}""").get ==
        "getRequiredVersions"
      )
  }

  test("field description"){
    assert(
      p.parse(p.fieldDeclaration, "int hoge;").get ==
        List("hoge")
    )

    assert(
      p.parse(p.fieldDeclaration, "int hoge, fuga;").get ==
        List("hoge", "fuga")
    )
    
    assert(
      p.parse(p.fieldDeclaration, "int hoge=3, fuga;").get ==
        List("hoge", "fuga")
    )

  }
}

