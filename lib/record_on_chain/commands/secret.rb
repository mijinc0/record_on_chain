require "pathname"
require_relative "./abstract_command"
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

        default_keyfile_name = Constants::D_DATAFILE_NAME + Constants::D_KEYFILE_SUFFIX

        default_path = Pathname.new( Dir.home )   +
                       Constants::MAINDIR_NAME    +
                       default_keyfile_name       ;
        keyfile_path = args[:keyfile_path] ? args[:keyfile_path] : default_path.to_s

        raise "#{keyfile_path} not found." unless File.exist?( keyfile_path )

        @keyfile = Keyfile.load( keyfile_path )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      def start
        secret = get_secret
        msg    = "Secret is [ #{secret} ]"
        roc_exit( :nomal_end , msg )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      private

      def get_secret
        answer  = ""
        cryptor = RecordOnChain::Crypto::DefaultCryptor.generate
        decrypt_func = ->( attempt ){ cryptor.decrypt( attempt,  @keyfile.salt , @keyfile.encrypted_secret ) }
        secret = @cli.encrypt_with_password( decrypt_func )
        # too many inccorect
        raise "3 incorrect password attempts. Please retry at first." if secret.nil?
        # if not nil, success to decrypt
        return secret
      end
    end
  end
end
