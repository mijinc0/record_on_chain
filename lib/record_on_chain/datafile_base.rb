require "yaml"
require_relative "./utils"

module RecordOnChain
  module DatafileBase
    # status_context = { :var => variable_name , :type => variable_type }
    def define_datafile_class(*status_context)

      variables = status_context.map{ |c| c[:var] }

      # [ presudo code ]
      # def initialize( args )
      #   @status1 = args[1]
      #   @status2 = args[2]
      #   ...
      # end
      define_method(:initialize) do |*args|
        variables.each_with_index do |var , index|
          # add "@" to sym
          # [e.g.] { var: :name , type: String } => :name => :@name
          var_name = ( "@#{var}" ).to_sym
          instance_variable_set( var_name, args[index] )
        end
      end

      attr_reader *variables

      # [ presudo code ]
      # def to_yml
      #   hash = [ status1: @status1, status2: @status2 ... ]
      #   return hash.to_yml
      # end
      define_method(:to_yml) do
        hash = {}
        instance_variables.each do |var_sym|
          # delete "@" from instance_variables sym
          # [e.g.] :@status1 => :status1
          key = var_sym.to_s.delete("@").to_sym
          # hash[ :status1 ] = @status1
          hash[key] = instance_variable_get( var_sym )
        end
        return hash.to_yaml
      end

      # [ presudo code ]
      # self.def generate( filepath , *args )
      #   obj = Datafile.new( *args )
      #   yml = obj.to_yml
      #   File.open( filepath, "w" ){ |f| f.write( yml ) }
      # end
      singleton_class.send( :define_method , :generate ) do |filepath , *args|
        datafile_obj = new( *args )
        yml = datafile_obj.to_yml
        File.open( filepath , "w" ){ |f| f.write( yml ) }
      end

      # [ presudo code ]
      # def self.load( filepath )
      #   hash = YAML.load_file( filepath )
      #   return from_hash( hash )
      # end
      singleton_class.send( :define_method , :load ) do |filepath|
        hash = YAML.load_file( filepath )
        # RecordOnChain::Utils
        hash = Utils.symbolize_hashkeys_rf( hash )
        return from_hash(hash)
      end

      # [ presudo code ]
      # def self.from_hash( hash )
      #
      #   types = { status1: String , status2: String , status3: Integer ,...}
      #
      #   return nil if hash[ :status1 ].nil? || hash[ :status1 ].class != types[ :status1 ]
      #   @status1 = hash[;status1]
      #
      #   return nil if hash[ :status2 ].nil?|| hash[ :status2 ].class != types[ :status2 ]
      #   @status2 = hash[;status2]
      #
      #   return nil if hash[ :status3 ].nil?|| hash[ :status3 ].class != types[ :status3 ]
      #   @status3 = hash[;status3]
      #   ...
      # end
      singleton_class.send( :define_method , :from_hash ) do |hash|
        args  = []
        
        types = status_context.map{ |c| c[:type] }

        variables.each_with_index do |var,index|
          value = hash[ var ]
          # If there is missing status in hash, return nil without generating the object
          return nil if value.nil?
          # If type of field does not match type of context, return nil without generating the object
          return nil unless value.class == types[ index ]
          args.push( value )
        end
        return new(*args)
      end
    end
  end
end
