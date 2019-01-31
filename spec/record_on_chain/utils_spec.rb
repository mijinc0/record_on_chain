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

  describe "self.CG_EXIT" do
    context "exit 0" do
      # make child process
      fork do
        RecordOnChain::Utils.CG_EXIT(0)
      end
      process_status = Process.wait2[1]
      it{ expect( process_status.exitstatus ).to eq 0 }
    end

    context "exit 1" do
      # make child process
      fork do
        RecordOnChain::Utils.CG_EXIT(1,"something worng")
      end
      process_status = Process.wait2[1]
      it{ expect( process_status.exitstatus ).to eq 1 }
    end
  end
end
