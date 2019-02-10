require_relative "./record_on_chain/version"
require_relative "./record_on_chain/command_loader"

module RecordOnChain
  class << self
    def exec
      command_name = ARGV.first
      command = CommandLoader.load( command_name )
      # command not fund
      if command.nil? then
        warn( "Error : #{command_name} command not found." )
        exit 1
      end
      # start
      command.start
    rescue => e
      warn( "Error : #{e.to_s}" )
      exit 1
    end
  end
end
