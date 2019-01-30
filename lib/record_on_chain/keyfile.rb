require "fileutils"
require "yaml"
require "digest/md5"
require "securerandom"
require_relative "./crypto/cryptor"
require_relative "./utils"

module RecordOnChain
  class Keyfile
    ## region static ##

    @@FILENAME = "keyfile.yml".freeze
    @@SECRET_LENGTH = 32.freeze
    @@SALT_LENGTH = 4.freeze

    def self.filename
      return @@FILENAME
    end

    def self.validate_password( passwd )
      # 0-9,a-z,A-Z, # $ % & @ / ? .
      pattern = /[^\w#\$%&@\/?\.]/
      return false unless (pattern =~ passwd).nil?
      return true
    end

    def self.generate( passwd, network_type, dir_path )
      # If file already exist, igonore this method.
      raise "keyfile already exist" if File.exist?( "#{dir_path}/#{@@FILENAME}" )
      # password has unacceptable chars
      raise "Error : you can only use [0-9, a-z, A-Z, #$%&@/?_. ] for passwrod. " unless validate_password( passwd )

      # salt : random 16bytes hex str
      salt = SecureRandom.hex(@@SALT_LENGTH)
      # secret : random 32bytes hex str
      secret = SecureRandom.hex(@@SECRET_LENGTH)
      # public key
      public_key = Nem::Keypair.new( secret ).public
      # address
      address = Nem::Unit::Address.from_public_key( public_key, network_type )
      # encrypt secret by passwd and salt
      cryptor = Crypto::Cryptor.new( Crypto::AES.new )
      encrypted_secret = cryptor.encrypt( passwd, salt, secret )
      # generate keyfile
      keyfile = Keyfile.new(network_type,salt,encrypted_secret,public_key,address)
      yml_str = keyfile.to_yml
      File.open( "#{dir_path}/#{@@FILENAME}", "w" ){ |f| f.write( yml_str ) }
    end

    def self.load( dir_path )
      data = YAML.load_file( "#{dir_path}/#{@@FILENAME}" )
      # symbolize keys
      data = Utils.symbolize_hashkeys_rf( data )
      # generate keyfile object
      return from_hash( data )
    end

    def self.from_hash( hash )
      return Keyfile.new( hash[:network_type], hash[:salt], hash[:encrypted_secret], hash[:public_key], hash[:address] )
    end

    def self.remove( path )
      FileUtils.remove( "#{path}/#{@@FILENAME}" )
    end

    ## region end ##

    ## region object ##

    def initialize( network_type, salt, encrypted_secret, public_key, address )
      # check arguments
      args = [ network_type, salt, encrypted_secret, public_key, address ]
      # if any arg empty, raise error
      args.each{ |arg| raise "Error : #{arg} is not found in keyfile." if arg.nil? || arg.empty? }
      @network_type = network_type
      @salt = salt
      @encrypted_secret = encrypted_secret
      @public_key = public_key
      @address = address
    end
    attr_reader :network_type, :public_key, :address

    def to_yml
      data = { network_type: @network_type, salt: @salt, encrypted_secret: @encrypted_secret, public_key: @public_key, address: @address }
      return YAML.dump( data )
    end

    def decrypt_secret( passwd )
      cryptor = Crypto::Cryptor.new( Crypto::AES.new )
      return cryptor.decrypt( passwd, @salt, @encrypted_secret )
    end
  end
end
