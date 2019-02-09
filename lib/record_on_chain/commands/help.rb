require_relative "./abstract_command"
require_relative "./init"
require_relative "./record"
require_relative "./secret"
require_relative "../utils"

module RecordOnChain
  module Commands
    class Help < AbstractCommand

      def self.description
        return "display usage"
      end

      def self.usage; end

      def initialize( argv= ARGV , cli= Cli.new )
        super( argv.first , cli )
      end

      def start
        command_names = [ "init", "record", "secret", "help" ]
        # command_name : description
        descriptions = {}
        # command_name : usage
        examples = {}

        command_names.each do |name|
          klass = Object.const_get( "RecordOnChain::Commands::#{name.capitalize}" )
          description = klass.send( :description )
          descriptions[ name ] = description unless description.nil?
          examples[ name ] = klass.usage unless klass.usage.nil?
        end

        @cli.puts_enhance_msg( "== Record on Chain HELP ==" )
        @cli.blank_line
        @cli.puts_underline_msg("descriptions")
        @cli.puts_hash( descriptions , nil , 1 )
        @cli.blank_line

        @cli.puts_underline_msg("usages")
        examples.each do | c_name, usage |
          @cli.out.puts( " [ #{c_name} ]" )
          @cli.out.puts( "#{usage}" )
          @cli.blank_line
        end
      end
    end
  end
end
