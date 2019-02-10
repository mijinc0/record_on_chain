module RecordOnChain
  # region generally
  MAINDIR_NAME = ".ro_chain".freeze

  # region crypto
  SECRET_LENGTH   = 32.freeze
  SALT_LENGTH     = 16.freeze
  CHECKSUM_LENGTH = 4.freeze

  # region datafile
  D_DATAFILE_NAME     = "default".freeze
  D_KEYFILE_SUFFIX    = "_key.yml".freeze
  D_CONFIGFILE_SUFFIX = "_config.yml".freeze

  D_KEYFILE_NAME    = ( D_DATAFILE_NAME + D_KEYFILE_SUFFIX ).freeze
  D_CONFIGFILE_NAME = ( D_DATAFILE_NAME + D_CONFIGFILE_SUFFIX ).freeze

  # region dirpath
  COMMANDS_DIRPATH  = File.expand_path( "../commands"     , __FILE__ ).freeze
  RESOURCES_DIRPATH = File.expand_path( "../../resources" , __FILE__ ).freeze
end
