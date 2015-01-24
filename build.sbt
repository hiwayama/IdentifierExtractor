name := "IdentifierExtractor"

scalaVersion := "2.10.2"

resolvers += "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"

libraryDependencies ++= Seq(
  "play" % "play_2.10" % "2.1.0", 
  "org.scalatest" % "scalatest_2.10" % "1.9.1" % "test"
)
