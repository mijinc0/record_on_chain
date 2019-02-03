require_relative "./datafile_base"

module RecordOnChain
  class Config
    extend DatafileBase
    define_datafile_class(
      :keyfile_path,
      :recipient,
      :add_node,
    )
  end
end
