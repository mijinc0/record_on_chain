require "highline"

module RecordOnChain
  class Cli
    def initialize( input=$stdin , output=$stdout )
      @input  = input
      @output = output
    end

    def in ; return @input ; end
    def out; return @output; end

    ATTR_OFF = "\e[0m".freeze

    ENHANCE = "\e[1m".freeze
    # style      : bold

    UNDERLINE = "\e[4m".freeze
    # style      : underline

    ERROR = "\e[31m\e[1m".freeze
    # color      : red
    # style      : bold

    SUCCESS = "\e[32m\e[1m".freeze
    # color      : green
    # style      : bold

    CAUTION = "\e[43m\e[30m\e[1m".freeze
    # background : yellow
    # color      : black
    # style      : bold

    ATTENTION = "\e[40m\e[36m\e[1m"
    # background : black 40
    # char       : cyan 36
    # others     : bold 1

    attributes = [ "enhance", "underline", "error", "success", "caution", "attention" ]
    attributes.each do |attr|
      const = self.const_get( attr.upcase )
      # def enhance_str( str )
      #   ENHANCE + str + ATTR_OFF
      # end
      define_method( "#{attr}_str" ){ |str| const + str + ATTR_OFF }
      # def puts_enhance_msg( msg )
      #   puts( enhance_str( msg ) )
      # end
      define_method( "puts_#{attr}_msg" ){ |msg| @output.puts( send( "#{attr}_str" , msg ) ) }
    end

    def blank_line( size= 1 )
      puts( "\n"*size )
    end

    def agree( what )
      return get_highline.agree( "Are you sure you want to #{what}? (y)es or (n)o" )
    end

    def decide_password
      user_password = password_operation_base( 5 )do |answer|
        # Enter pass again to see if it is equal
        conf_answer = get_highline.ask("- Please enter your password again (confirm)"){ |q| q.echo = "*" }
        answer == conf_answer
      end
      return user_password
    end

    def encrypt_with_password( decrypt_func )
      decrypted_secret = password_operation_base( 3 ) do |attempt|
        decrypted = decrypt_func.call( attempt )
        if decrypted.empty? then
          false # failure
        else
          # you can get decrypted data from attempt after valid_process
          attempt.replace( decrypted )
          true # success
        end
      end
      return decrypted_secret
    end

    def puts_hash( hash , attribute= nil, indent= 0 )
      formatted = format_hash( hash , indent )
      formatted = send( "#{attribute}_str" , formatted ) unless attribute.nil?
      @output.puts( formatted )
    end

    # [ example ]
    # {alice:"alice",bob:"bob",dylan:"dylan",carol:"carol"}
    #
    # alice : alice
    # bob   : bob
    # dylan : dylan
    # carol : carol
    def format_hash( hash, indent= 0, split_word=" : "  )
      # get max :key word length
      max_key_length = hash.map{ |pair| pair.first.size }.max{ |a,b| a <=> b }
      # initialize output
      output = ""
      hash.each do |key,val|
        output << " " * indent
        output << padding( key.to_s , max_key_length )
        output << split_word
        output << val.to_s
        output << "\n"
      end
      return output
    end

    private

    def get_highline
      return HighLine.new( @input, @output )
    end

    # If you want to exit this method when password is valid,
    # you should use "return" in valid_process block.
    def password_operation_base( attempts_count, &valid_process )
      result = ""
      1.step do |count|
        # incorrect many times
        return nil if count > attempts_count
        # user enter pass here
        answer = get_highline.ask("- Please enter your password"){ |q| q.echo = "*" }
        # valid process
        return answer if valid_process.call( answer )
        # If it is empty, the attempt is incorrect.
        puts_enhance_msg( "Your passwords don't match.Please try again." )
      end
    end

    def padding( word , padded_size , char=" " )
      num_of_pad_required = padded_size - word.size
      # no need padding
      return word if num_of_pad_required <= 0
      # padding exec
      return word + (char * num_of_pad_required)
    end
  end
end
