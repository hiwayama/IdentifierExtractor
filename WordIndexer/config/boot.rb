# -*- coding: utf-8 -*-

require 'yaml'
require 'active_record'
require 'logger'

# get path of current directory
cpath = File.expand_path("../",__FILE__)
APP_PATH = File.expand_path("../../", __FILE__)

# read database setting file
SETTING = YAML::load(open("#{cpath}/database.yml"))["development"]

# connect to database
if SETTING["adapter"] == "sqlite3"
  SETTING["database"] = File.expand_path(SETTING["database"], APP_PATH)
end
ActiveRecord::Base.establish_connection( SETTING )


# set logger
# this line is necessary to apply migrations
ActiveRecord::Base.logger = Logger.new("#{cpath}/../log/database.log")

# require tables
require "#{cpath}/../db/table"
