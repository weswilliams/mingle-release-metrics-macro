require 'rake/packagetask'

%w[rubygems rake rake/clean rake/testtask fileutils macro_development_toolkit].each { |f| require f }

Dir['tasks/**/*.rake'].each { |t| load t }

desc "Runs all units and integration tests and specifications"
task :test => ['test:units', 'test:integration', 'spec']

task :package => [:test]

Rake::PackageTask.new("release_metrics", :noversion) do |p|
  p.need_zip = true
  p.package_files.include(
      "init.rb",
      "Rakefile",
      "lib/**/*.*",
      "tasks/**/*.*",
      "assets/**/*.*",
      "views/**/*.*",
      "test/**/*.*"
  )
end
