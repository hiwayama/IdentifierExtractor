#!/usr/local/bin/ruby -Ku
# -*- coding: utf-8 -*-

cpath = File.expand_path("../",__FILE__)

Dir.glob("#{cpath}/tables/*.rb").each do |path|
	name = File.basename(path, ".*")
  autoload name.classify.to_sym, path
end
