require "spec_helper"
require "fileutils"
require_pairfile

RSpec.describe "Commands" do
  describe "start" do
    let(:tmp_dirpath){ File.expand_path("../../../../tmp",__FILE__) }
    let(:main_dirpath){ "#{tmp_dirpath}/#{RecordOnChain::Constants::MAINDIR_NAME}" }
    let(:args){ [ "-p" , tmp_dirpath ] }
    subject{  RecordOnChain::Commands::Init.new( args ) }

    before(:each)do
      # overwrite roc_exit
      subject.define_singleton_method(:roc_exit){ |code , msg=""| return code }
      # mock ask of highline
      allow( subject ).to receive(:ask){ "test" }
      # mock choose of highline (it means use default)
      allow( subject ).to receive(:choose){}
    end

    after(:each){ FileUtils.rm_rf( main_dirpath ) }

    it do
      result = subject.start
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
