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

      def validate_password( passwd )
        pattern = /[^\w#\$%&@\/?\.+]/
        (pattern =~ passwd).nil? ? true : false
      end

      def hex_str?( str , byte_size= -1 )
        str_size = str.size
        return false if str_size.odd?
        except_prefix = str.start_with?("0x") ? str[ 1 , str_size-2 ] : str
        # validate size ( byte_size <= 0 ---> ignore )
        return false if byte_size > 0 && str_size != byte_size*2
        not_hex = /[^\dabcdef]/
        return !not_hex.match?( except_prefix )
      end

      private

      def get_parent_command_name
        caller_locations(2).first.label
      end
    end
  end
end
