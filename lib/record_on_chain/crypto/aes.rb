# reference
# https://docs.ruby-lang.org/ja/latest/class/OpenSSL=3a=3aCipher.html
require 'openssl'

module RecordOnChain
  module Crypto
    class AES
      def encrypt( passwd, salt, secret )
        return crypto_func_base( passwd, salt, secret, :encrypt )
      end

      def decrypt( passwd, salt, encrypted_data )
        return crypto_func_base( passwd, salt, encrypted_data, :decrypt )
      end

      private
      def generate_base
        return OpenSSL::Cipher.new("AES-256-CBC")
      end

      def calc_key_and_initvector( passwd, salt )
        aes = generate_base
        # key_inv = key( aes.key_len byte ) | inv ( aes.iv_len byte )
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1( passwd, salt, 2000, aes.key_len + aes.iv_len )
        key = key_iv[ 0,aes.key_len ]
        iv  = key_iv[ aes.key_len, aes.iv_len ]
        return { key: key, initvector: iv }
      end

      def set_key_iv( aes, passwd, salt )
        key_iv = calc_key_and_initvector( passwd, salt )
        aes.key = key_iv[ :key ]
        aes.iv  = key_iv[ :initvector ]
      end

      #@param [passwd] passwd
      #@param [salt] salt
      #@param [data] :encrypt => secret_data , decrypt => encrypted_data
      #@param [encrypt_or_decrypt] :encrypt or :decrypt (symbol)
      def crypto_func_base( passwd, salt, data, encrypt_or_decrypt )
        aes = generate_base
        aes.send( encrypt_or_decrypt )
        set_key_iv( aes, passwd, salt )
        output = ""
        output << aes.update( data )
        output<< aes.final
        return output
      end
    end
  end
end
