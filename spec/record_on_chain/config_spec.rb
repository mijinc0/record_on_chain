require "spec_helper"
require "yaml"
require_pairfile

# yml is used for config format
RSpec.describe RecordOnChain::Config do
  let(:tmp_dir_path){ File.expand_path("../../../tmp/",__FILE__) }
  let(:fixture_path){ File.expand_path("../",__FILE__) }
  let(:config_filename){ RecordOnChain::Config.filename }

  describe "#create" do

    let(:default_values){ {nem_config:{recipient:"TAAHOVLXGXS6GWVTQMOZ27M4WXWBBEABHGCMF5IH"}} }

    context "nomal" do
      before{ RecordOnChain::Config.create( tmp_dir_path, default_values ) }
      after{ File.delete("#{tmp_dir_path}/#{config_filename}") }
      it{ expect( YAML.load_file("#{tmp_dir_path}/#{config_filename}") ).to eq default_values }
    end

    context "error : Illegal file path" do
      let( :illegal_path ){ File.expand_path("../../../tmp/not_exist_file/",__FILE__) }
      it{ expect{ RecordOnChain::Config.create( illegal_path, default_values ) }.to raise_error( Errno::ENOENT ) }
    end
  end

  describe "getters" do
    subject{ RecordOnChain::Config.load( fixture_path ) }

    describe "#nem_config" do
      let( :expected ){ { recipient: "TAAHOVLXGXS6GWVTQMOZ27M4WXWBBEABHGCMF5IH" } }
      it{ expect( subject.nem_config() ).to eq expected }
    end
  end
end
