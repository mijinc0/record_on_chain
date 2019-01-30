module RecordOnChain
  module Utils
    class << self
      # reflexivity symbolize hash keys
      def symbolize_hashkeys_rf( hash_data )
        result = {}
        hash_data.each do |key,value|
          value = symbolize_hashkeys_rf( value ) if value.class.equal?( {}.class )
          result[ key.to_sym ] = value
        end
        return result
      end

      def bytes_to_hex( bytes )
        return bytes.unpack("H*").first
      end

      def hex_to_bytes( hex )
        return [hex].pack("H*")
      end

      def CG_EXIT( exit_code , what_you_should_do = "" )
        puts( "RecordOnChain ** #{get_parent_command_name} ** command is interrupted." ) unless exit_code == 0
        puts( what_you_should_do ) unless exit_code == 0 && what_you_should_do.empty?
        exit exit_code
      end

      private

      def get_parent_command_name
        caller_locations(2).first.label
      end
    end
  end
end
