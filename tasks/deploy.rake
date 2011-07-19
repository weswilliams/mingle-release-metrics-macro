namespace :macro do |ns|

  mingle_folder = File.expand_path(File.join(ENV['MINGLE_LOCATION']))

  task :full_deploy => ["macro:stop_mingle","macro:clean_deploy","macro:deploy","macro:start_mingle"]

  task :full_start_mingle => ["macro:start_postgresql","macro:start_mingle"]

  task :start_postgresql do
    system "sudo service postgresql start;sleep 15"
  end

  task :stop_mingle do
    system "#{mingle_folder}/MingleServer stop; sleep 10"
  end

  task :start_mingle => ["macro:stop_mingle"] do
    system "export JAVA_HOME=/usr/lib/jvm/java-6-sun;" +
           "export PATH=$JAVA_HOME/bin:$PATH;" +
           "unset GEM_HOME GEM_PATH;" +
           "#{mingle_folder}/MingleServer --mingle.dataDir=~/mingle/data start"
  end

  task :clean_deploy do
    puts "Remove deployed macro if it exists"
    macro_name = File.basename(File.expand_path(File.join(File.dirname(__FILE__), '..')))
    FileUtils.rm_rf(File.join(ENV['MINGLE_LOCATION'], 'vendor', 'plugins', macro_name))
  end

  task :deploy do
    macro_folder = File.expand_path(".")
    mingle_plugins_folder = File.join(ENV['MINGLE_LOCATION'], 'vendor', 'plugins', "release_metrics")
    FileUtils.cp_r(macro_folder, mingle_plugins_folder)
    puts "#{macro_folder} successfully deployed to #{mingle_plugins_folder}. Mingle server must be restarted."
  end

end