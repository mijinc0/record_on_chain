require "spec_helper"
require_pairfile

RSpec.describe RecordOnChain::Crypto::AES do
  let( :secret ){ "this is secret" }
  let( :hex_salt ){ "a65d565e91572d5708e8000e4a44ff60" }
  let( :salt ){ [hex_salt].pack("H*") }
  let( :passwd ){ "passwd" }
  let( :hex_encrypted_data ){ "7488dcc7b53a02ee8c3d27bb65bd4f41" }
  let( :encrypted_data ){ [hex_encrypted_data].pack("H*") }

  subject{ RecordOnChain::Crypto::AES.new }

  describe "#encrypt" do
    it{ expect( subject.encrypt( passwd, salt, secret ).unpack("H*").first ).to eq hex_encrypted_data }
  end

  describe "#decrypt" do
    it{ expect( subject.decrypt( passwd, salt, encrypted_data ) ).to eq secret }
  end
end
