# coding: UTF-8

require 'fileutils'

desc 'Downloads dependencies into the vendor/lib/ directory.'
task :deps do
  `mvn dependency:copy-dependencies`
  FileUtils.mkdir_p 'vendor/lib'
  Dir['target/dependency/*.jar'].each do |dependency|
    FileUtils.cp dependency, 'vendor/lib/'
  end
end
