namespace 'import' do
  desc 'Import data from Districts source in db/seed_files/School_districts_Boundaries.csv'
  task :districts => :environment do
    DistrictsImporter.import
  end

  desc 'Import data from Schools source in db/seed_files/School_directory.csv'
  task :schools => :environment do
    SchoolDirectoryImporter.import
  end

  desc 'Import data from Feeder Patterns sources in db/seed_files/Grade_*.geojson files'
  task :feeder_patterns => :environment do
    FeederPatternsImporter.import
  end
end
