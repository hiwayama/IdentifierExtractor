
$:.unshift File.expand_path("../", __FILE__)

def recursive_search dir, extname, count
  Dir::entries(dir).each do |name|
    next if name[0] == "."
    abs_name = dir+"/"+name
    if File::ftype(abs_name).strip == "directory"
      count = recursive_search(abs_name, extname, count)
    else
      # javaファイルならutf8化
      if File.extname(name) == extname
        count+=1
      end
    end
  end
  count
end

if __FILE__ == $0
  home = "/Users/iwayama"
  
  basis = "#{home}/Downloads/JavaSrcForReseach"
   
  dirs = {
    jetty_dir:  "#{basis}/Jetty6.1H8-sources/org", 
    swing_dir:  "#{basis}/src-jdk/javax/swing", 
    awt_dir:    "#{basis}/src-jdk/java/awt", 
    storm_dir:  "#{basis}/storm/storm-core", 
    hadoop_dir:   "#{basis}/hadoop-1.2.1/src/core" 
  }
"~/Downloads/JavaSrcForReseach/hadoop-1.2.1/src/core"
  dirs.each do |name, path|
    puts [name, recursive_search(path, ".java", 0)].join(":")
  end
end 




dir = "#{home}/Documents/workspace/scala/IdentifierExtractor/script"
puts recursive_search(dir, ".rb", 0)


