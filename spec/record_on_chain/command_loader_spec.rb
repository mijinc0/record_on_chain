require "spec_helper"
require_pairfile

RSpec.describe RecordOnChain::CommandLoader do
  describe "#load" do
    let(:dirpath){ File.expand_path( "../commands/dummy" , __FILE__ ) }
    let(:args){ ["alice","bob","carol"] }

    context "nomal" do
      it{ expect( RecordOnChain::CommandLoader.load( "dummy", args, dirpath ).call ).to eq args[2] }
    end

    context "not found" do
      it{ expect( RecordOnChain::CommandLoader.load( "notfound", args, dirpath ) ).to eq nil }
    end
  end
end
