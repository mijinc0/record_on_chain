require "pathname"
require "securerandom"
require "highline/import"
require_relative "./abstract_command"
require_relative "../keyfile"
require_relative "../config"
require_relative "../nem_controller"
require_relative "../constants"
require_relative "../crypto/default_cryptor"

module RecordOnChain
  module Commands
    class Record < AbstractCommand

      def self.description
        return "record message on nem(ver-1) chain"
      end

      def self.usage
        output =  " -p <value> => base path       ( default : $HOME              )\n" +
                  " -c <value> => configfile name ( defailt : default_config.yml )\n" +
                  " -m <value> => message you want to record ( *mandatory fields )\n\n" ;
        output << "(e.g.) configfile_name:my_config.yml , message:good_luck!\n"
        output << "=> $ rochain record -c my_config.yml -m good_luck!\n"
        return output
      end

      def initialize( argv = ARGV , cli = Cli.new )
        super( argv.first , cli )
        val_context = { "-p" => :path,
                        "-c" => :config,
                        "-m" => :msg }
        flag_context = {}

        args = squeeze_args_from_argv( val_context , flag_context , argv )

        @maindir_path = get_dirpath( args[:path] ) # String
        @config       = load_config( args[:config] )
        @keyfile      = load_keyfile
        @msg          = args[:msg]
        @nem          = create_nem_controller
      rescue => e
        roc_exit( :halt , "#{e.message}" )
      end

      def start
        # send
        result = send_tx
        # exit
        result[:success?] ? roc_exit( :nomal_end, "tx_hash [ #{result[:tx_hash]} ]" ) :
                            roc_exit( :halt     , "Fail to send tx. #{result[:message]}" )
      rescue => e
        roc_exit( :halt , e.message )
      end

      private

      # region get_dirpath

      def get_dirpath( dir_path )
        # default = homedir
        dir_path = dir_path ? dir_path : Dir.home
        pn = Pathname.new( dir_path )
        # dir not found
        raise "#{dir_path} directory not found." unless pn.directory?
        return ( pn + Constants::MAINDIR_NAME ).to_s
      end

      # region load_config & load_keyfile

      def load_config( name )
        default_confifile_name = Constants::D_DATAFILE_NAME + Constants::D_CONFIGFILE_SUFFIX
        configfile_name = name ? name : default_confifile_name
        configfile_path = "#{@maindir_path}/#{configfile_name}"
        return load_datafile( configfile_path , "config" )
      end

      def load_keyfile
        return load_datafile( @config.keyfile_path , "keyfile" )
      end

      # base method of load_config & load_keyfile
      def load_datafile( datafile_path , class_name )
        # try to load
        full_class_name = "RecordOnChain::#{class_name.capitalize}"
        # get klass => klass.send( :load , path ) => klass.load( path )
        klass = Object.const_get( full_class_name )
        datafile = klass.send( :load , datafile_path )
        # if fail to load becaseu any field is illegal
        raise "Fail to load #{name}." if datafile.nil?
        # success
        return datafile
      end

      # region create_nem_controller

      def create_nem_controller
        node_urls = get_node_urls
        return NemController.new( node_urls , @keyfile.network_type )
      end

      def get_node_urls
        # get preset node file path
        preset_filepath = File.expand_path("../../../resources/",__FILE__)
        # testnet? mainnet?
        network_type = @keyfile.network_type.to_s
        preset_filepath << "/preset_#{network_type}_nodes"
        # load preset node set
        preset_node_urls = []
        File.foreach( preset_filepath ){ |url| preset_node_urls.push( url.chomp ) }
        # select nodes
        node_count = 10
        nodes = preset_node_urls.sample( node_count )
        # add nodes thas is specified by user
        # These nodes have priority
        add_node = @config.add_node
        # add in fornt
        nodes = add_node + nodes
        return delete_invalid_nodes( nodes )
      end

      # delete invalid form
      def delete_invalid_nodes( urls )
        # delete empty and including unsafe char
        urls.delete_if{ |u| u.empty? || u.match?( URI::UNSAFE ) }
        # modify
        return urls.map do |u|
          # if not start_with http:// or https://. add prefix
          u.start_with?( "http://" , "https://" ) ? u : "http://" << u
        end
      end

      # region send_tx

      def send_tx
        raise "massage not found. Nothing to record." if @msg.nil? || @msg.empty?
        # get secret from keyfile and password.
        secret = get_secret
        # get address from the secret to use for confirm.
        sender_address = NemController.address_from_secret( secret , @keyfile.network_type )
        # for confirm
        recipient = @config.recipient
        # prepare transfer tx
        @nem.prepare_tx( recipient , @msg )
        # confirm
        confirm_before_send_tx( sender_address , recipient )
        # broadcast tx and return result
        return @nem.send_transfer_tx( secret )
      end

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

      def confirm_before_send_tx( sender_address , recipient )
        fee = @nem.calc_fee/1000000.to_f
        address_info = @nem.get_address_status( sender_address )

        # caoutino if address has too many xem
        balance = address_info[:balance]
        too_many_xem = 1000 * 1000000
        @cli.puts_caution_msg( "Caution! There are too many xems in this address!　This warning is displayed when it is more than #{too_many_xem/1000000}xem." ) if balance > too_many_xem

        # multisig not supported
        raise "Error : Sorry, multisig is not supported." if address_info[:multisig]

        # confirmation info
        @cli.puts_attention_msg( "!! confirm !!" )
        status = { :sender    => sender_address,
                   :recipient => recipient,
                   :data      => @msg,
                   :fee       => "#{fee} xem"}
        @cli.puts_hash( status , :enhance )
        # if not agree, cancel to send
        raise "Cancel to record." unless @cli.agree( "record" )
      end
    end
  end
end
