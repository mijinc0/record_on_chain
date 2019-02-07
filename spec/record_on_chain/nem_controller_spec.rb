require "spec_helper"
require_relative "../webmock_helper"
require_pairfile

RSpec.describe RecordOnChain::NemController do

  NORMAL_NIS_URL = NEM_URL
  BAD_NIS_URL = "http://127.0.0.1:9999"
  let( :normal_node_set ){ [ NORMAL_NIS_URL ] }
  let( :bad_node_set ){ [ BAD_NIS_URL, BAD_NIS_URL, BAD_NIS_URL ] }
  let( :net_type ){ :testnet }

  describe "#send_transfer_tx" do
    let( :recipient ){ "TALIC37AGCDGQIBK3Y2IPFHSRAJ4HLJPNJDTSTJ7" }
    let( :private_key ){ "51f42e592e4bc527f890a5a4b1fad95c0f22c03662f728edf2f7d75d640205b2" }

    context "return nomal responses" do
      let( :nem_controller ){ RecordOnChain::NemController.new( normal_node_set , net_type ) }
      let( :expected ){ { success?: true, message: "SUCCESS", tx_hash: "c1786437336da077cd572a27710c40c378610e8d33880bcb7bdb0a42e3d35586" } }
      before{ nem_controller.prepare_tx( recipient, "message" ) }

      it{ expect( nem_controller.send_transfer_tx( private_key ) ).to eq expected }
    end

    context "return bad responses" do
      before do
        nem_controller.prepare_tx( recipient, "message" )
        WebMock.disable!
      end
      after  { WebMock.enable! }
      let( :nem_controller ){ RecordOnChain::NemController.new( bad_node_set , net_type ) }
      let( :expected ){ { success?: false, message: "Exhausted node pool", error_type:"RuntimeError" } }
      it{ expect( nem_controller.send_transfer_tx( private_key ) ).to eq expected }
    end

    context "Error : No node" do
      nodes = []
      it{ expect{ RecordOnChain::NemController.new( nodes , recipient , net_type ) }.to raise_error ArgumentError }
    end
  end

  describe "#get_address_status" do
    let( :nem_controller ){ RecordOnChain::NemController.new( normal_node_set , net_type ) }
    let( :expected ){ { balance: 2000000 , multisig: false } }
    it{ expect( nem_controller.get_address_status( "NCYP7E7S67LB4G4Y4RJWE7REFBZI4EXJ73MRKIWW" ) ).to eq expected }
  end
end
