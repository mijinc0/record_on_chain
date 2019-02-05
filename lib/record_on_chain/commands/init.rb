require "pathname"
require "securerandom"
require "highline/import"
require_relative "./abstract_command"
require_relative "../keyfile"
require_relative "../config"
require_relative "../constants"

module RecordOnChain
  module Commands
    class Init < AbstractCommand
      def initialize( argv = ARGV )
        super( argv )
        set_args_from_argv( "-p" => :path, "-s" => :secret )
      end

      # you can specify maindir path with argument.
      def start
        # default = homedir
        path = @args[:path] ? @args[:path] : Dir.home
        # dir not found
        roc_exit(:halt,"#{path} directory not found.") unless Dir.exist?( path )

        # generate maindir
        maindir_path = Pathname.new( path ) + Constants::MAINDIR_NAME
        maindir_path.mkdir unless maindir_path.directory?

        # region keyfile
        keyfile_name = ask("please enter new keyfile name"){ |q| q.default = "default" }
        keyfile_path = maindir_path + ( keyfile_name << "_key.yml" )
        generate_keyfile( keyfile_path , @args[:secret] )

        # region config
        configfile_name = ask("please enter new config file name"){ |q| q.default = "default" }
        configfile_path = maindir_path + ( configfile_name << "_config.yml" )
        # create default_values from loaded keyfile
        keyfile = Keyfile.load( keyfile_path )
        default_values  = { keyfile_path: keyfile_path.to_s , recipient: keyfile.address, add_node: "" }
        # generate config
        generate_config( configfile_path , default_values )
        # nomal_end
        roc_exit( :nomal_end )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      private

      def decide_network_type
        net_type = :testnet
        choose do |menu|
          menu.prompt = "- Please choose network type"
          menu.choice( :testnet ){}
          menu.choice( :mainnet ){ net_type = :mainnet }
        end
        return net_type
      end

      def decide_password
        answer = ""
        5.times do |count|
          answer = ask("please enter your password"){ |q| q.echo = "*" }
          conf_answer = ask("please enter your password again (confirm)"){ |q| q.echo = "*" }
          # if match, go next step
          break if answer == conf_answer
          say( "Your passwords don't match.Please try again." )
          # incorrect many times
          if count == 4 then
            roc_exit( :halt , "5 incorrect password attempts. Please retry at first." )
          end
        end
        return answer
      end

      def generate_keyfile( keyfile_path , secret = nil )
        # skip if already exist
        if keyfile_path.exist? then
          $stderr.puts( "#{keyfile_path.to_s} already exists. skip generate keyfile." )
          return
        end

        # check secret size
        unless secret.nil? || secret.size == Constants::SECRET_LENGTH then
          err = "Illegal secret size. secret should be 32byte-hex_string."
          roc_exit( :halt , err )
        end

        # decide network_type
        network_type = decide_network_type

        # decide password
        password = decide_password

        # cretae cryptor
        cryptor = Crypto::Cryptor.new( Crypto::AES.new )

        # create status
        salt       = SecureRandom.hex( Constants::SALT_LENGTH )
        secret     = secret ? secret : SecureRandom.hex( Constants::SECRET_LENGTH )
        public_key = Nem::Keypair.new( secret ).public
        address    = Nem::Unit::Address.from_public_key( public_key, network_type )
        encrypted_secret = cryptor.encrypt( password, salt, secret )

        # generate
        Keyfile.generate( keyfile_path.to_s, network_type, salt, encrypted_secret, public_key, address )
      end

      def generate_config( configfile_path , default_values )
        # skip if already exist
        if configfile_path.exist? then
          $stderr.puts( "#{configfile_path.to_s} already exists. skip generate config file." )
          return
        end
        Config.generate(
          configfile_path.to_s,
          default_values[:keyfile_path],
          default_values[:recipient],
          default_values[:add_node]
        )
      end
    end
  end
end
