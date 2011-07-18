require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./test/spec/**/*_spec.rb"
  # Put spec opts in a file named .rspec in root
end

namespace :test do

  Rake::TestTask.new(:units) do |t|
    t.libs << "test/unit"
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << "test/integration"
    t.pattern = 'test/integration/*_test.rb'
    t.verbose = true
  end

end

