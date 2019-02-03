require "spec_helper"
require_pairfile

module RecordOnChain
  class Dog
    extend DatafileBase
    define_datafile_class( :name, :age )
  end
end

RSpec.describe "define_datafile_class method" do
  # check define initialize and getter
  describe "initialize and getter" do
    subject{ RecordOnChain::Dog.new( "doge" , 5 ) }

    it{ expect( subject.name ).to eq "doge" }
    it{ expect( subject.age ).to eq 5 }
  end

  describe "self.generate and load" do
    before(:all)do
      @path = File.expand_path("../../../tmp/datafile_test.yml",__FILE__)
      RecordOnChain::Dog.generate( @path, "doge", 5 )
    end

    after(:all){ File.delete( @path ) }

    subject{ RecordOnChain::Dog.load( @path ) }
    it{ expect( subject.name ).to eq "doge" }
    it{ expect( subject.age ).to eq 5 }
  end
end
