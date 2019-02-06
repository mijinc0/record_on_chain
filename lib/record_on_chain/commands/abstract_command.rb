require "optparse"

module RecordOnChain
  module Commands
    # base of command class
    class AbstractCommand
      def initialize( argv = ARGV )
        @argv = argv
        @args = {}
      end

      def set_args_from_argv( context )
        opts = OptionParser.new
        # set to args according to context.
        context.each{ |key,val| opts.on("#{key} VAL"){|v| @args[val] = v} }
        # raise erro if user set unknown option
        opts.parse( @argv )
      rescue OptionParser::InvalidOption => e
        # invalid Option
        roc_exit( :halt, e.message )
      end

      private

      def roc_exit( code , msg="" )
        known_codes = [:nomal_end,:halt]
        raise "Unknown exit code #{code}" unless known_codes.include?(code)
        # get child class name
        command_name = self.class.to_s.downcase
        # puts exit messages
        case code
        when :nomal_end
          # nomal end
          $stdout.puts( "Exit NOMAL : #{command_name} command execution succeede.\n" )
          exit 0
        when :halt
          # something happen
          err = "Exit ERROR    : #{command_name} command execution failed.\n" +
                "[ ERROR MESSAGE ]\n" +
                "#{msg}"
          warn( err )
          exit 1
        end
      end
    end
  end
end
