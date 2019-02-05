module RecordOnChain
  class CommandLoader
    @@COMMANDS_DIRPATH = File.expand_path( "../commands" , __FILE__ ).freeze

    def self.load( name, dirpath = @@COMMANDS_DIRPATH )
      # except abstract sourcefile
      return nil if name.include?("abstract")
      # expand command file path
      filepath = File.expand_path( name, dirpath ) << ".rb"
      # check file existance
      return nil unless File.file?( filepath )
      # require command file
      require( filepath )
      # generate object
      class_name = "RecordOnChain::Commands::#{name.capitalize}"
      return Object.const_get( class_name ).new
    end
  end
end
