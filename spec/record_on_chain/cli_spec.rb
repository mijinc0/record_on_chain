require "spec_helper"
require_pairfile

RSpec.describe RecordOnChain::Cli do

  subject{ RecordOnChain::Cli.new( mock_input, mock_output ) }

  let(:mock_highline){ Object.new }
  let(:mock_output  ){ Object.new }
  let(:mock_input   ){ Object.new }

  before(:each) do
    allow( subject ).to receive( :get_highline ).and_return( mock_highline )

    mock_output.define_singleton_method(:puts){ |m| return m }
    mock_input.define_singleton_method(:gets){} # not need so far
  end

  describe "#put_hash" do
    let(:hash){ { alice: "alice", bob: "bob", dylan: "dylan", carol: "carol" } }
    let(:expected){
      "alice : alice\n" +
      "bob   : bob\n"   +
      "dylan : dylan\n" +
      "carol : carol\n"
    }
    it{ expect( subject.puts_hash( hash ) ).to eq expected }
  end

  describe "#decide_password" do
    context "nomal" do
      before(:each){ mock_highline.define_singleton_method(:ask){ |m| "passwd" } }

      it{ expect( subject.decide_password ).to eq "passwd" }
    end

    context "error : incorrect many times" do
      before(:each) do
        INPUTS = ["passwd","miss"]*5
        mock_highline.define_singleton_method(:ask){ |m| INPUTS.shift }
      end

      it{ expect( subject.decide_password ).to eq nil }
    end
  end

  describe "#encrypt_with_password" do
    context "nomal" do
      let(:decrypt_func){ ->(attempt){ "decrypted_data" } }

      before(:each){ mock_highline.define_singleton_method(:ask){ |m| "passwd" } }

      it{ expect( subject.encrypt_with_password( decrypt_func ) ).to eq "decrypted_data" }
    end

    context "error : incorrect many times" do
      let(:decrypt_func){ ->(attempt){ "" } }

      before(:each){ mock_highline.define_singleton_method(:ask){ |m| "miss_passwd" } }

      it{ expect( subject.encrypt_with_password( decrypt_func ) ).to eq nil }
    end
  end
end
