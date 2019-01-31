require_relative "./datafile_base"

module RecordOnChain
  class Keyfile
    extend DatafileBase
    define_datafile_class(
      :network_type,:salt,
      :salt,
      :encrypted_secret,
      :public_key,
      :address
    )
  end
end
