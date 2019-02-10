require "pathname"
require_relative "./abstract_command"
require_relative "./mod_command"
require_relative "../constants"
require_relative "../keyfile"
require_relative "../crypto/default_cryptor"

module RecordOnChain
  module Commands
    class Secret < AbstractCommand

      def self.description
        return "recover secret from keyfile"
      end

      def self.usage
        output = <<-EOS
 -k <value> => keyfile path ( default : $HOME/.ro_chain/default_key.yml )

 (e.g.) keyfile_path:/home/user/doc/.ro_chain/my_key.yml
 => $ rochain secret -k /home/user/doc/.ro_chain/my_key.yml
        EOS
        return output
      end

      def initialize( argv= ARGV , cli= Cli.new )
        super( argv.first , cli )
        val_context  = { "-k" => :keyfile_path }
        flag_context = {}

        args = squeeze_args_from_argv( val_context , flag_context , argv )

        default_path = Pathname.new( Dir.home ) +
                       MAINDIR_NAME   +
                       D_KEYFILE_NAME ;
        keyfile_path = args[:keyfile_path] ? args[:keyfile_path] : default_path.to_s

        @keyfile = load_datafile( keyfile_path , "keyfile" )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      def start
        secret = get_secret( @cli, @keyfile )
        msg    = "Secret [ #{secret} ]"
        roc_exit( :nomal_end , msg )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      private

      include M_LoadDatafile
      include M_GetSecret
    end
  end
end
