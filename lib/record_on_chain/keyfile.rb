require_relative "./datafile_base"

module RecordOnChain
  class Keyfile
    extend DatafileBase
    define_datafile_class(
      { :var => :network_type     , :type => String },
      { :var => :salt             , :type => String },
      { :var => :encrypted_secret , :type => String },
      { :var => :public_key       , :type => String },
      { :var => :address          , :type => String }
    )
  end
end
