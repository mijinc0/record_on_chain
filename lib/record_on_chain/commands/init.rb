require "nem"
require "pathname"
require "securerandom"
require "highline/import"
require_relative "./abstract_command"
require_relative "../utils"
require_relative "../keyfile"
require_relative "../config"
require_relative "../constants"
require_relative "../crypto/cryptor"

module RecordOnChain
  module Commands
    class Init < AbstractCommand
      def initialize( argv = ARGV )
        super( argv )
        set_args_from_argv( "-p" => :path,
                            "-s" => :secret,
                            "-k" => :keyfile_name,
                            "-c" => :configfile_name,)
      end

      # you can specify maindir path with argument.
      def start
        # default = homedir
        path = @args[:path] ? to_absolute_path( @args[:path] ) : Dir.home
        # dir not found
        raise "#{path} directory not found." unless Dir.exist?( path )

        # generate maindir
        maindir_path = Pathname.new( path ) + Constants::MAINDIR_NAME
        maindir_path.mkdir unless maindir_path.directory?

        # region keyfile
        keyfile_name = @args[:keyfile_name] ? @args[:keyfile_name] : "default"
        keyfile_name << "_key.yml"
        keyfile_path = maindir_path + ( keyfile_name )
        $stdout.puts( "\e[1m [ Start gnerate #{keyfile_name} ]\e[0m" )
        generate_keyfile( keyfile_path , @args[:secret] )

        # region config
        configfile_name = @args[:configfile_name] ? @args[:configfile_name] : "default"
        configfile_name << "_config.yml"
        configfile_path = maindir_path + ( configfile_name )
        $stdout.puts( "\e[1m [ Start gnerate #{configfile_name} ]\e[0m" )
        # create default_values from loaded keyfile
        keyfile = Keyfile.load( keyfile_path )
        default_values  = { keyfile_path: keyfile_path.to_s , recipient: keyfile.address, add_node: [] }
        # generate config
        generate_config( configfile_path , default_values )
        $stdout.puts( "\n" )

        # nomal_end
        roc_exit( :nomal_end )
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      private

      def to_absolute_path( path )
        pn = Pathname.new(path)
        return path if pn.absolute?
        # convert relative to absolute
        return File.expand_path( pn.to_s , Dir.pwd )
      end

      def decide_network_type
        net_type = :testnet
        $stdout.puts("- Please choose network type")
        choose do |menu|
          menu.prompt = ""
          menu.choice( :testnet ){}
          menu.choice( :mainnet ){ net_type = :mainnet }
        end
        return net_type
      end

      def decide_password
        answer = ""
        5.times do |count|
          answer = ask("- Please enter your password"){ |q| q.echo = "*" }
          conf_answer = ask("- Please enter your password again (confirm)"){ |q| q.echo = "*" }
          # if match, go next step
          break if answer == conf_answer
          say( "  Your passwords don't match.Please try again." )
          # incorrect many times
          raise "5 incorrect password attempts. Please retry at first." if count == 4
        end
        return answer
      end

      def generate_keyfile( keyfile_path , secret = nil )
        # skip if already exist
        if keyfile_path.exist? then
          $stdout.puts( "#{keyfile_path.to_s} already exists. skip generate keyfile." )
          return
        end

        # check hex_str
        unless secret.nil? || Utils.hex_str?( secret ) then
          err = "Illegal secret. secret should be 32byte-hex_string (64chars)."
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
          $stdout.puts( "#{configfile_path.to_s} already exists. skip generate config file." )
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
