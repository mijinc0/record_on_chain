require "spec_helper"
require "securerandom"
require "digest/md5"
require_relative "../../../lib/record_on_chain/utils"
require_relative "../../../lib/record_on_chain/crypto/aes"
require_pairfile

RSpec.describe RecordOnChain::Crypto::Cryptor do
  let(:aes){ RecordOnChain::Crypto::AES.new }
  # bytes data
  let( :passwd ){"passwd"}
  let( :secret ){ SecureRandom.bytes(32) }
  let(  :salt  ){ SecureRandom.bytes(16) }
  let(:checksum){ Digest::MD5.digest( secret )[0,4] }
  let(:encrypted_data){ aes.encrypt( passwd, salt , secret + checksum ) }
  # hex data
  let(:h_secret){ RecordOnChain::Utils.bytes_to_hex( secret ) }
  let( :h_salt ){ RecordOnChain::Utils.bytes_to_hex(  salt  ) }
  let(:h_encrypted_data){ RecordOnChain::Utils.bytes_to_hex( encrypted_data ) }

  subject{ RecordOnChain::Crypto::Cryptor.new(aes) }

  describe "self.encrypt" do
    it{ expect( subject.encrypt( passwd, h_salt, h_secret ) ).to eq h_encrypted_data }
  end

  describe "self.decrypt" do
    context "nomal" do
      it{ expect( subject.decrypt( passwd, h_salt, h_encrypted_data ) ).to eq h_secret }
    end

    context "fail to decrypt" do
      it{ expect( subject.decrypt( "badpasswd", salt, h_encrypted_data ) ).to eq "" }
    end
  end
end
