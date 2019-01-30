module RecordOnChain
  class CommandLoader
    @@DIRPATH = File.expand_path( "../commands" , __FILE__ ).freeze

    def self.load( name, args, dirpath = @@DIRPATH )
      # expand command file path
      filepath = File.expand_path( name, dirpath ) << ".rb"
      # check file existance
      return nil unless File.file?( filepath )
      # require command file
      require( filepath )
      # return
      ->(){ Commands.send( name , args ) }
    end
  end
end
