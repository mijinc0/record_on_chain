require "spec_helper"
require "fileutils"
require_pairfile

RSpec.describe "Commands" do
  describe "self.init" do
    let(:tmp_dirpath){ File.expand_path("../../../../tmp",__FILE__) }
    let(:main_dirpath){ "#{tmp_dirpath}/#{RecordOnChain::Constants::MAINDIR_NAME}" }

    after(:each){ FileUtils.rm_rf( main_dirpath ) }

    before(:each)do
      # mock ask of highline
      allow( Object ).to receive(:ask){ "test" }
      # mock choose of highline (it means use default)
      allow( Object ).to receive(:choose){}
    end

    it do
      result = RecordOnChain::Commands.init( { path: tmp_dirpath } )
      # check result
      expect( result ).to eq :nomal_end
      # check main dir
      expect( Dir.exist?( main_dirpath ) ).to eq true
      # check keyfile
      keyfile = RecordOnChain::Keyfile.load("#{main_dirpath}/test_key.yml")
      expect( keyfile.network_type ).to eq :testnet
      # ckeck configfile
      configfile = RecordOnChain::Config.load("#{main_dirpath}/test_config.yml")
    end
  end
end
