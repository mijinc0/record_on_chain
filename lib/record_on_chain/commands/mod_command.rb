require_relative "../keyfile"
require_relative "../crypto/default_cryptor"

# module set for command
module RecordOnChain
  module Commands

    module M_LoadDatafile
      # base method of load_config & load_keyfile
      def load_datafile( datafile_path , class_name )
        # try to load
        full_class_name = "RecordOnChain::#{class_name.capitalize}"
        # get klass => klass.send( :load , path ) => klass.load( path )
        klass = Object.const_get( full_class_name )
        datafile = klass.send( :load , datafile_path )
        # if fail to load becaseu any field is illegal
        raise "Fail to load #{class_name}.Please check the fields of #{class_name}." if datafile.nil?
        # success
        return datafile
      end
    end

    module M_GetSecret
      # recover secret from keyfile and user password
      def get_secret( cli , keyfile )
        answer  = ""
        cryptor = RecordOnChain::Crypto::DefaultCryptor.generate
        decrypt_func = ->( attempt ){ cryptor.decrypt( attempt,  keyfile.salt, keyfile.encrypted_secret ) }
        secret = cli.encrypt_with_password( decrypt_func )
        # too many inccorect
        raise "3 incorrect password attempts. Please retry at first." if secret.nil?
        # if not nil, success to decrypt
        return secret
      end
    end

  end
end
