require "spec_helper"
require "securerandom"
require_pairfile

RSpec.describe RecordOnChain::Utils do
  describe "self.symbolize_hashkeys_rf" do
    let(:hash_data){ {"A"=>"alice", "B"=>{"one"=>"bob","two"=>"brown"} } }
    let(:symbolized){ {A:"alice", B:{ one:"bob", two:"brown" } } }
    it{ expect( RecordOnChain::Utils.symbolize_hashkeys_rf( hash_data ) ).to eq symbolized }
  end

  describe "self.validate_password" do
    let(:ok_chars){ "saoh/ji#safa$ogeha+39782f@q287y" }
    let(:bad_char){ "=" }

    it{ expect( RecordOnChain::Utils.validate_password( ok_chars ) ).to eq true }
    it{ expect( RecordOnChain::Utils.validate_password( ok_chars + bad_char ) ).to eq false }
  end
end
