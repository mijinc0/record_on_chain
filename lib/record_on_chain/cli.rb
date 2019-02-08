require "highline"

module RecordOnChain
  class Cli
    def initialize( input=$stdin , output=$stdout )
      @input  = input
      @output = output
    end

    def in ; return @input ; end
    def out; return @output; end

    def enhanced_msg( msg )
      out = ENHANCE + msg + ATTR_OFF + "\n"
      @stdout.puts( out )
    end

    def caution_msg( msg )
      out = CAUTION + msg + ATTR_OFF + "\n"
      warn( out )
    end

    def error_msg( msg )
      out = ERROR + msg + ATTR_OFF + "\n"
      warn( out )
    end

    def success_msg( msg )
      out = SUCCESS + msg + ATTR_OFF + "\n"
      @stdout.puts( out )
    end

    def puts_hash( hash )
      formatted = format_hash( hash )
      @output.puts( formatted )
    end

    def decide_password
      hl = HighLine.new( @input, @output )
      user_password = password_operation_base( 5 )do |answer|
        # Enter pass again to see if it is equal
        conf_answer = hl.ask("- Please enter your password again (confirm)"){ |q| q.echo = "*" }
        answer == conf_answer
      end
      return user_password
    end

    def encrypt_with_password( decrypt_func )
      password_operation_base( 3 ) do |attempt|
        decrypted = decrypt_func.call( attempt )
        if decrypted.empty? then
          false # failure
        else
          # you can get decrypted data from attempt after valid_process
          attempt.replace( decrypted )
          true # success
        end
      end
    end

    # region constants

    ATTR_OFF = "\e[0m".freeze

    ENHANCE = "\e[1m".freeze
    # style      : bold

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

    private
    # [ example ]
    # {alice:"alice",bob:"bob",dylan:"dylan",carol:"carol"}
    #
    # alice : alice
    # bob   : bob
    # dylan : dylan
    # carol : carol
    def format_hash( hash , split_word=" : " )
      # get max :key word length
      max_key_length = hash.map{ |pair| pair.first.size }.max{ |a,b| a <=> b }
      # initialize output
      output = ""
      hash.each do |key,val|
        output << padding( key.to_s , max_key_length )
        output << split_word
        output << val.to_s
        output << "\n"
      end
      return output
    end

    # If you want to exit this method when password is valid,
    # you should use "return" in valid_process block.
    def password_operation_base( attempts_count, &valid_process )
      hl = HighLine.new( @input, @output )
      result = ""
      1.step do |count|
        # incorrect many times
        return nil if count > attempts_count
        # user enter pass here
        answer = hl.ask("- Please enter your password"){ |q| q.echo = "*" }
        # valid process
        return answer if valid_process.call( answer )
        # If it is empty, the attempt is incorrect.
        warn( "Your passwords don't match.Please try again." )
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
