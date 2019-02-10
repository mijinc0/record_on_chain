require "digest/md5"
require_relative '../utils'
require_relative '../constants'

module RecordOnChain
  module Crypto
    class Cryptor
      def initialize( crypto_engine )
        @crypto_engine = crypto_engine
      end

      def generate_secret
        return SecureRandom.hex( SECRET_LENGTH )
      end

      def generate_salt
        return SecureRandom.hex( SALT_LENGTH )
      end

      def encrypt( passwd, hex_salt, hex_secret )
        b_secret = Utils.hex_to_bytes( hex_secret )
        # add checksum to secret
        b_secret << calc_checksum( b_secret )
        b_salt   = Utils.hex_to_bytes( hex_salt )
        encrypted = @crypto_engine.encrypt( passwd, b_salt, b_secret )
        return Utils.bytes_to_hex( encrypted )
      end

      def decrypt( passwd, hex_salt, hex_encrypted_data )
        b_data = Utils.hex_to_bytes( hex_encrypted_data )
        b_salt = Utils.hex_to_bytes( hex_salt )
        decrypted = ""
        begin
          # At this point it is not known whether the decrypted data is correct or not.
          # You should verify decrypted data with checksum.
          decrypted = @crypto_engine.decrypt( passwd, b_salt, b_data )
        rescue OpenSSL::Cipher::CipherError
          # fail to encrypt
          return ""
        end
        # validate checksum
        secret_length = decrypted.size - CHECKSUM_LENGTH
        secret_part   = decrypted[0,secret_length]
        checksum_part = decrypted[secret_length..-1]
        checksum = calc_checksum( secret_part )
        # not match checksum
        return "" unless checksum_part == checksum
        # match checksum
        return Utils.bytes_to_hex( secret_part )
      end

      private

      def calc_checksum( data )
        # MD5 Hash [0..CCHECKSUM_LENGTH]
        return Digest::MD5.digest( data )[ 0 , CHECKSUM_LENGTH ]
      end
    end
  end
end
