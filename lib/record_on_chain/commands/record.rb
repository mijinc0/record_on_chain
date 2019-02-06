require "pathname"
require "securerandom"
require "highline/import"
require_relative "../keyfile"
require_relative "../config"
require_relative "../constants"

module RecordOnChain
  module Commands
    class Record < AbstractCommand
      def initialize( argv = ARGV )
        super( argv )
        set_args_from_argv( "-p" => :path, "-c" => :config, "-m" => :msg )
      end

      def start
        # default = homedir
        dir_path = get_dirpath
        # load config
        @config = load_config( dir_path )
        # load keyfile
        @keyfile = load_keyfile
        # create nem_controller
        @nem = create_nem_controller
        # send
        result = send_tx
        # exit
        result[:success?] ? roc_exit( :nomal_end ) : roc_exit( :halt, result[:message] )
      rescue => e
        roc_exit( :halt , e.message )
      end

      private

      # region get_dirpath

      def get_dirpath
        # default = homedir
        dir_path = @args[:path] ? @args[:path] : Dir.home
        # dir not found
        raise "#{dir_path} directory not found." unless Dir.exist?( dir_path )
        return dir_path
      end

      # region load_config & load_keyfile

      def load_config( dir_path )
        configfile_name = @args[:config] ? @args[:config] : "default_config.yml"
        configfile_path = "#{dir_path}/#{configfile_name}"
        return load_datafile( configfile_path , "config" )
      end

      def load_keyfile
        return load_datafile( @config.keyfile_path , "keyfile" )
      end

      # base method of load_config & load_keyfile
      def load_datafile( datafile_path , name )
        # try to load
        class_name = "RecordOnChain::#{name.capitalize}"
        # get klass => klass.send( :load , path ) => klass.load( path )
        klass = Object.const_get( class_name )
        datafile = klass.send( :load , datafile_path )
        # if fail to load becaseu any field is illegal
        raise "Fail to load #{name}." if datafile.nil?
        # success
        return datafile
      end

      # region create_nem_controller

      def create_nem_controller
        node_urls = get_node_urls
        return Controller::NemController.new( node_urls , @keyfile.network_type )
      end

      def get_node_urls
        # get preset node file path
        preset_filepath = File.expand_path("../../../resources/",__FILE__)
        # testnet? mainnet?
        preset_filepath << "/preset_#{@keyfile.network_type.to_s}_nodes"
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

      # region record_on_chain

      def send_tx
        msg = get_msg_from_args
        # get secret from keyfile and password.
        secret = get_secret
        # get address from the secret to use for confirm.
        sender_address = Controller::NemController.address_from_secret( secret , @keyfile.network_type )
        # for confirm
        recipient = @config.recipient
        confirm_before_send_tx( msg , sender_address , recipient )
        # broadcast tx and return result
        return @nem.send_transfer_tx( recipient , msg , secret )
      end

      def get_msg_from_args
        raise "massage not found. Nothing to record." if @args[:msg].nil? || @args[:msg].empty?
        return @args[:msg]
      end

      def get_secret
        answer  = ""
        cryptor = RecordOnChain::Crypto::Cryptor.new( RecordOnChain::Crypto::AES.new )
        3.times do |count|
          answer    = ask("please enter your password"){ |q| q.echo = "*" }
          decrypted = cryptor.decrypt( answer , @keyfile.salt , @keyfile.encrypted_secret )
          # If it is NOT empty, the attempt is success.
          return decrypted unless decrypted.empty?
          # If it is empty, the attempt is incorrect.
          say( "Your passwords don't match.Please try again." )
          # incorrect many times
          raise "3 incorrect password attempts. Please retry at first." if count == 2
        end
      end

      def confirm_before_send_tx( msg , sender_address , recipient )
        # background : black 40
        # char       : green 32
        # others     : bold 1 , underline 4
        $stdout.print( "\e[32m\e[40m\e[1m\e[4m" )
        $stdout.puts ( "[ confirm ]" )
        $stdout.print( "\e[0m" ) # all attributes off
        # print status
        conf = "sender    : #{sender_address}\n"
             + "recipient : #{recipient}\n"
             + "data      : #{msg}\n"
        $stdout.print( "\e[1m" ) # bold
        $stdout.puts ( conf )
        $stdout.print( "\e[0m" ) # all attributes off
        answer = agree("Are you sure you want to record? (y)es or (n)o")
        raise "Cancel to record." if answer == false
      end
    end
  end
end
