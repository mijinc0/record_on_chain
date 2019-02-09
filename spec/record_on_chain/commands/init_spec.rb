require "spec_helper"
require "fileutils"
require_pairfile

RSpec.describe "Commands" do
  describe "init start" do

    subject{ RecordOnChain::Commands::Init.new( argv, cli ) }

    let(:cli){ RecordOnChain::Cli.new }

    let(:argv) do
      ("init" +
       "-s 51f42e592e4bc527f890a5a4b1fad95c0f22c03662f728edf2f7d75d640205b2 " +
       "-t " +
       "-k init_test -c init_test " +
       "-p #{TMP_DIRPATH}").split(" ");
    end

    before(:each){ allow( subject ).to receive( :roc_exit ){ |c,m| c } }

    context "nomal" do
      before(:each){ allow( cli ).to receive( :decide_password ){ "password" } }

      after(:each) do
        File.delete( "#{TMP_DIRPATH}/#{RecordOnChain::Constants::MAINDIR_NAME}/init_test_key.yml" )
        File.delete( "#{TMP_DIRPATH}/#{RecordOnChain::Constants::MAINDIR_NAME}/init_test_config.yml" )
      end

      it{ expect( subject.start ).to eq :nomal_end }

      it do
        subject.start
        # check with existance
        File.exist?( "#{TMP_DIRPATH}/#{RecordOnChain::Constants::MAINDIR_NAME}/init_test_key.yml" )
        File.exist?( "#{TMP_DIRPATH}/#{RecordOnChain::Constants::MAINDIR_NAME}/init_test_config.yml" )
      end
    end

    context "error : password" do
      before(:each){ allow( cli ).to receive( :decide_password ){ nil } }

      it{ expect( subject.start ).to eq :halt }
    end
  end
end
