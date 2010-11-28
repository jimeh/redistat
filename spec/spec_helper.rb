# add project-relative load paths
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# require stuff
require 'redistat'
require 'rspec'
require 'rspec/autorun'

# use the test Redistat instance
Redistat.connect(:port => 8379, :db => 15)
Redistat.flush
