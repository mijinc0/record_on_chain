require "nem"
require "pathname"
require_relative "./abstract_command"
require_relative "../utils"
require_relative "../keyfile"
require_relative "../config"
require_relative "../constants"
require_relative "../nem_controller"
require_relative "../crypto/default_cryptor"

module RecordOnChain
  module Commands
    class Init < AbstractCommand

      def self.description
        return "initialize RecordOnChain"
      end

      def self.usage
        output = <<-EOS
 -p <value> => base path         ( default : $HOME              )
 -s <value> => 32byte hex secret ( default : random hex         )
 -k <value> => keyfile name      ( default : default_key.yml    )
 -c <value> => configfile name   ( defailt : default_config.yml )
 -t         => network type      ( defailt : false -> mainnet   )

 (e.g.) secret:XXX , keyfile_name:mykey.yml , network_type:testnet
 => $ rochain init -k mykey.yml -s XXX -t
        EOS
        return output
      end

      def initialize( argv= ARGV , cli= Cli.new )
        super( argv.first , cli )
        val_context  = { "-p" => :path,
                         "-s" => :secret,
                         "-k" => :keyfile_name,
                         "-c" => :configfile_name }
        flag_context = { "-t" => :testnet }

        args = squeeze_args_from_argv( val_context , flag_context , argv )

        @secret          = args[:secret]
        @network_type    = args[:testnet] ? "testnet" : "mainnet"
        @maindir_path    = get_maindir_path( args[:path] ) # Pathname obj
        @keyfile_path    = get_datafile_path( "keyfile"    , args[:keyfile_name]    ) # Pathname obj
        @configfile_path = get_datafile_path( "configfile" , args[:configfile_name] ) # Pathname obj
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      # you can specify maindir path with argument.
      def start
        @cli.puts_enhance_msg( "[ Start gnerate keyfile ]" )
        generate_keyfile

        @cli.puts_enhance_msg( "[ Start gnerate configfile ]" )
        generate_config

        @cli.blank_line

        # nomal_end
        roc_exit( :nomal_end )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      private

      def get_maindir_path( base_path )
        # default = homedir
        base_path = base_path ? to_absolute_path( base_path ) : Dir.home
        # dir not found
        raise "#{base_path} directory not found." unless Dir.exist?( base_path )
        # generate maindir
        maindir_path = Pathname.new( base_path ) + MAINDIR_NAME
        # mkdir if not exist
        maindir_path.mkdir unless maindir_path.directory?
        return maindir_path
      end

      def to_absolute_path( path )
        if Pathname.new(path).absolute? then
          return path # no change
        else
          return File.expand_path( path , Dir.pwd )
        end
      end

      def get_datafile_path( type , name )
        datafile_name = name ? name : D_DATAFILE_NAME
        # add suffix to prevent conflicts
        datafile_name += RecordOnChain.const_get( "D_#{type.upcase}_SUFFIX" )
        # to path
        return @maindir_path + datafile_name
      end

      def generate_keyfile
        # skip if already exist
        if @keyfile_path.exist? then
          @cli.out.puts( "#{@keyfile_path.to_s} already exists. skip generate keyfile." )
          return
        end

        # check hex_str
        validate_secret_form

        # decide password
        password = decide_password

        # cretae cryptor
        cryptor  = Crypto::DefaultCryptor.generate

        # create status
        salt       = cryptor.generate_salt
        secret     = @secret ? @secret : cryptor.generate_secret
        public_key = NemController.public_from_secret( secret )
        address    = NemController.address_from_public( public_key, @network_type )
        encrypted_secret = cryptor.encrypt( password, salt, secret )
        # generate
        Keyfile.generate( @keyfile_path.to_s, @network_type, salt, encrypted_secret, public_key, address )
        # display address
        @cli.puts_attention_msg( "New keyfile address is #{address}" )
      end

      def validate_secret_form
        raise "Illegal secret. Secret should be 32byte-hex_string (64chars)." unless @secret.nil? || Utils.hex_str?( @secret , 32 )
      end

      def decide_password
        pass = @cli.decide_password
        raise "5 incorrect password attempts." if pass.nil?
        return pass
      end

      def generate_config
        # skip if already exist
        if @configfile_path.exist? then
          @cli.out.puts( "#{@configfile_path.to_s} already exists. skip generate config file." )
          return
        end

        # create default_values from loaded keyfile
        keyfile = Keyfile.load( @keyfile_path )
        # generate
        Config.generate( @configfile_path.to_s, @keyfile_path.to_s, keyfile.address, [] )
      end
    end
  end
end
