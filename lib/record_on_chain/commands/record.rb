require "pathname"
require "securerandom"
require "highline/import"
require_relative "../keyfile"
require_relative "../config"
require_relative "../constants"

module RecordOnChain
  module Commands
    class Record
      def start
        # default = homedir
        dir_path = args[:path] ? args[:path] : Dir.home
        # dir not found
        unless Dir.exist?( path ) then
          $stderr.puts( "#{dir_path} directory not found." )
          return :halt
        end

        configfile_name = args[:config] ? args[:config] : "default_config.yml"
        configfile_path = "#{dir_path}/#{configfile_name}"
        # file not found
        unless File.exist?( configfile_path ) then
          $stderr.puts( "#{configfile_path} file not found." )
          return :halt
        end
        config = Config.load( configfile_path )
        # config.nil? == true means fail to load
        if config.nil? then
          $stderr.puts( "Fail to load config.Please make sure config status." )
          return :halt
        end

        keyfile_name = args[:keyfile] ? args[:keyfile] : "default_key.yml"
        keyfile_path = "#{dir_path}/#{keyfile_name}"
        # file not found
        unless File.exist?( keyfile_path ) then
          $stderr.puts( "#{keyfile_path} file not found." )
          return :halt
        end
        keyfile = Keyfile.load( keyfile_path )
        if keyfile.nil? then
          $stderr.puts( "Fail to load keyfile.Please make sure config status." )
          return :halt
        end

        # load preset node set
        preset_nodes_filepath = File.expand("../../../resource/preset_nodes",__FILE__)
        preset_node_urls = []
        File.foreach( preset_nodes_filepath )do |url|
          preset_nodes.push(url)
        end
        # select nodes
        nodes_count = 10
        nodes = preset_nodes.sample( nodes_count )
        # add user config node
        nodes.unshift( config[:add_node] )

        # create nem_controller
      rescue => e
        $stderr.puts("Error : #{e.mesage}")
        return :halt
      end
    end
  end
end
