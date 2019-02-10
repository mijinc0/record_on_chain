require "bundler/setup"
require "record_on_chain"
require "pathname"

# make tmp dir for test
TMP_DIRPATH = File.expand_path( "../../tmp" , __FILE__ ).freeze
Dir.mkdir( TMP_DIRPATH ) unless Dir.exist?( TMP_DIRPATH )

# method that requires file that is one-to-one with test file.
def require_pairfile
  # root path [ ex. /home/user/project/ ]
  root_path = Pathname.new( Dir.pwd )
  # caller path [ ex. /home/user/project/spec/test_spec.rb ]
  caller_file_path = caller_locations.first.path
  # path where root_path is deleted from caller_path. [ ex. spec/test_spec.rb ]
  except_root_part = caller_file_path[ (root_path.to_s.size + 1)..-1 ]
  # to array [ ex. [ spec , test_spec.rb ] ]
  path_elements = except_root_part.split("/")
  # replace "spec" with "lib" [ ex. [ spec , test_spec.rb ] ]
  path_elements[0] = "lib"
  # slice "_spec" part from filename [ ex. [ lib , test.rb ] ]
  path_elements[-1].slice!("_spec")
  # make parifile_path [ ex. /home/user/project/lib/test.rb ]
  pair_file_path = root_path.join( *path_elements ).to_s
  # require parifile if it exist
  require "#{pair_file_path}" if File.exist?( pair_file_path )
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
