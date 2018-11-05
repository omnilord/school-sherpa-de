class RawFeederPatternsImporter
  def self.import
    external_feeder_import_status = system('bash', Rails.root.join('scripts', 'load_feeder_patterns.sh').to_s)
    raise StandrdError, 'Failed to load feeder patterns' unless external_feeder_import_status
  end
end
