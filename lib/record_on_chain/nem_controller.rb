require "nem"

module RecordOnChain
  module Controller
    class NemController
      @@NET_TYPES = [:testnet , :mainnet].freeze

      def initialize( node_url_set , net_type = :testnet )
        raise ArgumentError,"Node set must not be empty." if node_url_set.empty?
        raise ArgumentError,"Unknown network type.[:testnet,:mainnet]" unless @@NET_TYPES.include?(net_type)

        # make node_pool from node_set
        node_objects = []
        node_url_set.each do |url|
          node_object = Nem::Node.new( url: url )
          node_objects.push( node_object )
        end
        @node_pool = Nem::NodePool.new( node_objects )
        @net_type = net_type
      end

      def send_transfer_tx( recipient_str, msg, private_key )
        check_address( recipient_str )
        result = broadcast_transfer_tx( recipient_str, msg, private_key )
        return result
      end

      # default log path : stdout
      def set_log_path( dir_path )
        log_name = "nem_controller.log"
        Nem.logger = Logger.new( dir_path + log_name )
      end

      private

      # check whether address matches net_type
      def check_address( recipient_str )
        initial = recipient_str.upcase[0]
        error_msg = "Illegal address. You should make sure address"
        case initial
        when "T" then
          raise ArgumentError,error_msg  unless @net_type == :testnet
        when "N" then
          raise ArgumentError,error_msg  unless @net_type == :mainnet
        else
          raise ArgumentError,error_msg
        end
      end

      def broadcast_transfer_tx( recipient_str, msg, sender_keypair )
        no_sign_tx = Nem::Transaction::Transfer.new( recipient_str, 0, msg )
        announce_request = Nem::Request::Announce.new( no_sign_tx, sender_keypair )
        endpoint = Nem::Endpoint::Transaction.new( @node_pool )
        response = {}
        begin
          # If node pool has next node, it will automatically retry sending transaction.
          response = endpoint.announce( announce_request )
        rescue => e
          # all node failure
          return { success?: false, message: e.message, error_type: e.class.to_s }
        end
        # response.code == 1 ~> success
        # rasponse.code != 1 -> something failure
        case response.code
        when 1 then
          return { success?: true, message: response.message, tx_hash: response.transaction_hash }
        else
          return { success?: false, message: response.message, error_type: e.class.to_s }
        end
      end
    end
  end
end