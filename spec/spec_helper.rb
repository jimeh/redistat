# require "rubygems"
# require File.dirname(__FILE__) + "/../lib/redistat"
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'redistat'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end


Redistat.connect({:port => 8379, :db => 15})
Redistat.flush