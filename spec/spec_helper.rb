require "rubygems"
require File.dirname(__FILE__) + "/../lib/redistat"

Redistat.connect({:port => 8379, :db => 15})
Redistat.flush