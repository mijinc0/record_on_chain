require_relative "./aes"
require_relative "./cryptor"

module RecordOnChain
  module Crypto
    class DefaultCryptor
      def self.generate
        return Crypto::Cryptor.new( Crypto::AES.new )
      end
    end
  end
end
