require_relative "./datafile_base"

module RecordOnChain
  class Config
    extend DatafileBase
    define_datafile_class(
      { :var => :keyfile_path , :type => String },
      { :var => :recipient    , :type => String },
      { :var => :add_node     , :type => Array  }
    )
  end
end
