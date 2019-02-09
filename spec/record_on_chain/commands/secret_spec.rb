require "spec_helper"
require "fileutils"
require_pairfile

RSpec.describe "Commands" do
  describe "secret start" do

    before(:all) do
      # generate test_config.yml and test_key.yml in tmp dir
      @main_dirpath = "#{TMP_DIRPATH}/#{RecordOnChain::Constants::MAINDIR_NAME}"
      @key_path     = "#{@main_dirpath}/sec_test_key.yml"

      # keyfile
      @raw_key = { network_type: :testnet,
                   salt: "fca58e7c7c94803f41f8d291cfecd293",
                   encrypted_secret: "e362014c06b2ddf6ce8c9fd20308415481f740c9185a9b6e17d1e4192a5ac19e31c69a936e3480c70a19a6f5df8b9a97",
                   public_key: "28930ac41c7d4efb1b0329dbf11229f1103e484103b68898640d7843907a5d58",
                   address: "TA4F2IBLLM5YCTN6MXQ32QBN3HY5C7TVDM72LQ5X" }

      Dir.mkdir( @main_dirpath ) unless Dir.exist?( @main_dirpath )
      File.open( @key_path  , "w" ){ |f| f.puts( @raw_key.to_yaml  ) }
    end

    # remove test_conf & test_key
    after(:all){ File.delete( @key_path ) }

    subject{ RecordOnChain::Commands::Secret.new( argv, cli ) }

    let(:cli){ RecordOnChain::Cli.new }
    let(:argv){ "secret -k #{@key_path}".split }

    before(:each){ allow( subject ).to receive( :roc_exit ){ |c,m| c } }

    context "nomal" do
      before(:each){ allow( cli ).to receive( :encrypt_with_password ){ "51f42e592e4bc527f890a5a4b1fad95c0f22c03662f728edf2f7d75d640205b2" } }

      it{ expect( subject.start ).to eq :nomal_end }
    end

    context "error : bad secret" do
      before(:each){ allow( cli ).to receive( :encrypt_with_password ){ nil } }

      it{ expect( subject.start ).to eq :halt }
    end
  end
end
