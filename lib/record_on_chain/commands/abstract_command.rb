require "optparse"
require_relative "../cli"

module RecordOnChain

  module Commands
    # base of command class
    class AbstractCommand
      def initialize( command_name , cli= Cli.new )
        @command_name = command_name
        @cli = cli
      end

      def start
        raise NotImplementedError.new
      end

      def squeeze_args_from_argv( val_context= {} , flag_context= {} , argv= ARGV )
        opts = OptionParser.new
        args = {}
        # set to args according to hash_context.
        val_context.each { |key,val| opts.on("#{key} VAL"){|v| args[val] = v} }
        # set to args according to flag_context
        flag_context.each{ |key,val| opts.on("#{key}"){|v| args[val] = true} }
        # raise erro if user set unknown option
        # except first because @argv.first is command name
        opts.parse( argv )
        return args
      end

      private

      def roc_exit( code , msg="" )
        known_codes = [:nomal_end,:halt]
        raise "Unknown exit code #{code}" unless known_codes.include?(code)
        # puts exit messages
        case code
        when :nomal_end
          # nomal end
          out =  "Exit NOMAL : #{@command_name} command execution succeede.\n"
          out << msg
          @cli.puts_success_msg( out )
          exit 0
        when :halt
          # something happen
          err =  "Exit ERROR : #{@command_name} command execution failed.\n"
          err << "[ ERROR MESSAGE ]\n"
          err << "#{msg}"
          @cli.puts_error_msg( err )
          exit 1
        end
      end
    end
  end
end
