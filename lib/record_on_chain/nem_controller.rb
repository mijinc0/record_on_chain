require "nem"

module RecordOnChain
  class NemController
    @@NET_TYPES = [:testnet , :mainnet].freeze

    def self.address_from_secret( secret , network_type )
      kp = Nem::Keypair.new( secret )
      sender_address = Nem::Unit::Address.from_public_key( kp.public , network_type)
      return sender_address.to_s
    end

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
      @net_type  = net_type
    end

    def get_address_status( address )
      endpoint = Nem::Endpoint::Account.new( @node_pool )
      add = endpoint.find( address )
      multisig = !add.cosignatories.empty?
      return { balance: add.balance , multisig: multisig }
    end

    def prepare_tx( recipient_str, msg )
      check_address( recipient_str )
      # NOTE: Timestamp is set to -10 sec from Time.now.It prevent FAILURE_TIMESTAMP_TOO_FAR_IN_FUTURE
      @tx = Nem::Transaction::Transfer.new( recipient_str, 0, msg, timestamp: Time.now() -10 )
    end

    def calc_fee
      raise "Error : Please prepare tx before getting fee." if @tx.nil?
      fee = Nem::Fee::Transfer.new( @tx )
      return fee.to_i
    end

    def send_transfer_tx( private_key )
      raise "Error : Please prepare tx before sending." if @tx.nil?
      result = broadcast_transfer_tx( private_key )
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

    def broadcast_transfer_tx( sender_privatekey )
      sender_keypair   = Nem::Keypair.new( sender_privatekey )
      announce_request = Nem::Request::Announce.new( @tx, sender_keypair )
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
