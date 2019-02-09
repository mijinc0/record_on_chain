module RecordOnChain
  class Constants
    # region generally
    MAINDIR_NAME = ".ro_chain".freeze

    # region crypto
    SECRET_LENGTH   = 32.freeze
    SALT_LENGTH     = 16.freeze
    CHECKSUM_LENGTH = 4.freeze

    # region datafile
    D_DATAFILE_NAME = "default"
    D_KEYFILE_SUFFIX = "_key.yml"
    D_CONFIGFILE_SUFFIX = "_config.yml"
  end
end
