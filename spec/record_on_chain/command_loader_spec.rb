require "spec_helper"
require_pairfile

RSpec.describe RecordOnChain::CommandLoader do
  describe "#load" do
    let(:dirpath){ File.expand_path( "../commands/dummy" , __FILE__ ) }

    subject{ RecordOnChain::CommandLoader.load( "dummy", dirpath ) }

    context "nomal" do
      it{ expect( subject.start ).to eq "this is dummy" }
    end

    context "not found" do
      it{ expect( RecordOnChain::CommandLoader.load( "notfound", dirpath ) ).to eq nil }
    end
  end
end
