require 'rubygems'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test