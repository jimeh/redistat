require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'redistat'
    gem.summary = 'TODO: one-line summary of your gem'
    gem.description = 'TODO: longer description of your gem'
    gem.email = 'contact@jimeh.me'
    gem.homepage = 'http://github.com/jimeh/redistat'
    gem.authors = ['Jim Myhrberg']
    gem.add_dependency 'activesupport', '>= 2.3.0'
    gem.add_dependency 'json', '>= 1.0.0'
    gem.add_dependency 'redis', '>= 2.0.0'
    gem.add_dependency 'time_ext', '>= 0.2.6'
    gem.add_development_dependency 'rspec', '>= 2.0.1'
    gem.add_development_dependency 'yard', '>= 0.6.1'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


# Rspec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => [:start, :spec, :stop]


# Start/stop Redis test server
REDIS_DIR = File.expand_path(File.join("..", "spec"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "redis-test.conf")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")

desc "Start the Redis test server"
task :start do
  unless File.exists?(REDIS_PID)
    system "redis-server #{REDIS_CNF}"
  end
end

desc "Stop the Redis test server"
task :stop do
  if File.exists?(REDIS_PID)
    system "kill #{File.read(REDIS_PID)}"
    system "rm #{REDIS_PID}"
  end
end


# YARD Documentation
begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
