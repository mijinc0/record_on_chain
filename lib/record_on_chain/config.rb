require "yaml"
require_relative "./utils"

module RecordOnChain
  class Config
    @@FILENAME = "config.yml".freeze

    def self.filename
      return @@FILENAME
    end

    def self.create( dir_path, default_values={} )
      yml_str = YAML.dump( default_values )
      File.open( "#{dir_path}/#{@@FILENAME}", "w" ){ |f| f.write( yml_str ) }
    end

    def self.load( dir_path )
      map_data = YAML.load_file( "#{dir_path}/#{@@FILENAME}" )
      return Config.new( map_data )
    end

    attr_reader :nem_config

    def initialize( map_data )
      @nem_config = Utils.symbolize_hashkeys_rf( map_data )[:nem_config] || {}
    end
  end
end
