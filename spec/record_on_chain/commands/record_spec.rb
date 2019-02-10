require "spec_helper"
require "webmock_helper"
require "fileutils"
require "yaml"
require_pairfile

RSpec.describe "Commands" do
  describe "record start" do
    before(:all) do
      WebMock.enable!

      # generate test_config.yml and test_key.yml in tmp dir
      @tmp_dirpath  = File.expand_path("../../../../tmp/",__FILE__)
      @main_dirpath = "#{@tmp_dirpath}/#{RecordOnChain::MAINDIR_NAME}"
      @key_path     = "#{@main_dirpath}/rec_test_key.yml"
      @conf_path    = "#{@main_dirpath}/rec_test_config.yml"

      # keyfile
      @raw_key = { network_type: "testnet",
                   salt: "fca58e7c7c94803f41f8d291cfecd293",
                   encrypted_secret: "e362014c06b2ddf6ce8c9fd20308415481f740c9185a9b6e17d1e4192a5ac19e31c69a936e3480c70a19a6f5df8b9a97",
                   public_key: "28930ac41c7d4efb1b0329dbf11229f1103e484103b68898640d7843907a5d58",
                   address: "TA4F2IBLLM5YCTN6MXQ32QBN3HY5C7TVDM72LQ5X" }

      # config
      @raw_conf = { keyfile_path: @key_path,
                    recipient: "TA4F2IBLLM5YCTN6MXQ32QBN3HY5C7TVDM72LQ5X",
                    add_node: [ NEM_URL ] }

      Dir.mkdir( @main_dirpath ) unless Dir.exist?( @main_dirpath )
      File.open( @key_path  , "w" ){ |f| f.puts( @raw_key.to_yaml  ) }
      File.open( @conf_path , "w" ){ |f| f.puts( @raw_conf.to_yaml ) }
    end

    # remove test_conf & test_key
    after(:all) do
      WebMock.disable!

      File.delete( @key_path )
      File.delete( @conf_path )
    end

    subject{ RecordOnChain::Commands::Record.new( argv, cli ) }

    let(:cli){ RecordOnChain::Cli.new }
    let(:argv){ ("record -c rec_test_config.yml -p #{TMP_DIRPATH} -m good_luck!").split(" ") }

    before(:each) do
      allow( subject ).to receive( :roc_exit ){ |c,m| c }
      allow( subject ).to receive( :confirm_before_send_tx ){ |a,r| } # ignore confirm
    end

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
