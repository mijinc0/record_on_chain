require "spec_helper"
require_pairfile

RSpec.describe RecordOnChain::Cli do
  before(:all) do
    @mock_output = Object.new
    @mock_output.define_singleton_method(:puts){ |m| return m }

    @mock_input = Object.new
    @mock_input.define_singleton_method(:gets){} # not need so far
  end

  subject{ RecordOnChain::Cli.new( @mock_input, @mock_output ) }

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
      before(:each){ HighLine.define_method(:ask){ |m| "passwd" } }
      it{ expect( subject.decide_password ).to eq "passwd" }
    end

    context "error : incorrect many times" do
      before(:each) do
        INPUTS = ["passwd","miss"]*5
        HighLine.define_method(:ask){ |m| INPUTS.shift }
      end
      it{ expect( subject.decide_password ).to eq nil }
    end
  end

  describe "#encrypt_with_password" do
    context "nomal" do
      let(:decrypt_func){ ->(attempt){ "decrypted_data" } }
      before(:each){ HighLine.define_method(:ask){ |m| "passwd" } }

      it{ expect( subject.encrypt_with_password( decrypt_func ) ).to eq "decrypted_data" }
    end

    context "error : incorrect many times" do
      let(:decrypt_func){ ->(attempt){ "" } }
      before(:each){ HighLine.define_method(:ask){ |m| "miss_passwd" } }

      it{ expect( subject.encrypt_with_password( decrypt_func ) ).to eq nil }
    end
  end
end
