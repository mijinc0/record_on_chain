require "spec_helper"
require "fileutils"
require "yaml"
require "securerandom"
require "digest/md5"
require 'nem'
require_relative "../../lib/record_on_chain/crypto/cryptor"
require_pairfile

RSpec.describe RecordOnChain::Keyfile do
  let(:aes){ RecordOnChain::Crypto::AES.new }
  let(:cryptor){ RecordOnChain::Crypto::Cryptor.new(aes) }

  let( :tmp_path ){ File.expand_path( "../../../tmp", __FILE__ ) }
  let( :keyfile_name ){ RecordOnChain::Keyfile.filename }

  let(:passwd){ "passwd" }
  let(:salt){ "ba533b5ee4beba823cc102e6c5e97672" }
  let(:secret){ "b6dcd7d8bab5cfbbf3c679b3a59ec831033964ca4997fb7ca94562f12f97a7bc" }
  let(:encrypted_secret){ cryptor.encrypt( passwd, salt, secret ) }
  let(:network_type){ :testnet }

  let(:public_key){ Nem::Keypair.new( secret.unpack("H*").first ).public }
  let(:address){ Nem::Unit::Address.from_public_key( public_key, network_type ) }

  # first of each, create keyfile
  before( :each ) do
    data = { network_type: network_type,
             salt: salt,
             encrypted_secret: encrypted_secret,
             public_key: public_key,
             address: address }
    yml_str = YAML.dump( data )
    File.open( "#{tmp_path}/#{keyfile_name}", "w" ){ |f| f.write( yml_str ) }
  end

  # last of all, remove keyfile
  after( :all ) do
    keyfile_path = File.expand_path( "../../../tmp/#{RecordOnChain::Keyfile.filename}" ,__FILE__)
    FileUtils.remove( keyfile_path ) if File.exist?(keyfile_path)
  end

  subject{ RecordOnChain::Keyfile.load( tmp_path ) }

  describe "#network_type" do
    it{ expect( subject.network_type ).to eq network_type }
  end

  describe "#public_key" do
    it{ expect( subject.public_key ).to eq public_key }
  end

  describe "#address" do
    it{ expect( subject.address ).to eq address }
  end

  describe "#decrypt_secret" do
    context "nomal" do
      it{ expect( subject.decrypt_secret( passwd ) ).to eq secret }
    end

    context "fail to decrypt" do
      it{ expect( subject.decrypt_secret( "badpasswd" ) ).to eq "" }
    end
  end

  describe "self.remove" do
    before{ RecordOnChain::Keyfile.remove( tmp_path ) }
    it{ expect( File.exist?( "#{tmp_path}/#{keyfile_name}" )).to eq false }
  end

  describe "self.generate_keyfile" do
    before do
      # remove and re-generate
      FileUtils.remove( "#{tmp_path}/#{keyfile_name}" )
      RecordOnChain::Keyfile.generate( passwd , network_type , tmp_path )
    end

    # can load?
    subject{ RecordOnChain::Keyfile.load( tmp_path ) }
    # change address?
    it{ expect( subject.address ).not_to eq address }
  end
end
