require "spec_helper"
require "webmock_helper"
require "fileutils"
require "yaml"
require_pairfile

RSpec.describe "Commands" do
  describe "record start" do
    before(:all) do
      # generate test_config.yml and test_key.yml in tmp dir
      @tmp_dirpath  = File.expand_path("../../../../tmp/",__FILE__)
      @main_dirpath = "#{@tmp_dirpath}/#{RecordOnChain::Constants::MAINDIR_NAME}"
      @key_path     = "#{@main_dirpath}/test_key.yml"
      @conf_path    = "#{@main_dirpath}/test_config.yml"

      # keyfile
      @raw_key = { network_type: :testnet,
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
      File.delete( @key_path )
      File.delete( @conf_path )
    end

    let(:args){ [ "-p" , @tmp_dirpath , "-c" , "test_config.yml" , "-m" , "good_luck" ] }
    subject{ RecordOnChain::Commands::Record.new( args ) }

    before(:each) do
      # some methods are overridden by mock.
      # => roc_exit assign exit_code to @exit_code only once
      allow( subject ).to receive(:roc_exit){ |c , m| c }
      # => ask return "test" for password
      allow( subject ).to receive(:ask){ "test" }
      # => ignore confirm
      allow( subject ).to receive(:confirm_before_send_tx){ | m, a, r | }
    end

    context "nomal_end" do
      it{ expect( subject.start ).to eq :nomal_end }
    end

    context "halt : worng password" do
      before(:each){ allow( subject ).to receive(:ask){ "worngpass" } }
      it{ expect( subject.start ).to eq :halt }
    end

    context "halt : keyfile not found" do
      before( :each ){ File.delete( @key_path ) }
      after( :each ){ File.open( @key_path  , "w" ){ |f| f.puts( @raw_key.to_yaml  ) } }
      it{ expect( subject.start ).to eq :halt }
    end

    context "halt : configfile not found" do
      before( :each ){ File.delete( @conf_path ) }
      after( :each ){ File.open( @conf_path  , "w" ){ |f| f.puts( @raw_conf.to_yaml  ) } }
      it{ expect( subject.start ).to eq :halt }
    end
  end
end
