begin
  require 'macro_development_toolkit'
rescue LoadError
  require 'rubygems'
  require 'macro_development_toolkit'
end

if defined?(RAILS_ENV) && RAILS_ENV == 'production' && defined?(MinglePlugins)
  def load_all_files_in(dir)
    Dir[File.join(File.dirname(__FILE__), dir, '**', '*.rb')].each do |f|
      require f
    end
  end

  load_all_files_in('lib')

  MinglePlugins::Macros.register(CustomMacro::ReleaseMetrics, 'release_metrics')
end 