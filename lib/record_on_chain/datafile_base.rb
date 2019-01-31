require "yaml"

module RecordOnChain
  module DatafileBase
    def define_datafile_class(*status)

      # [ presudo code ]
      # def initialize( args )
      #   @status1 = args[1]
      #   @status2 = args[2]
      #   ...
      # end
      define_method(:initialize) do |*args|
        status.each_with_index do |s , index|
          # add "@" to sym
          # [e.g.] :status => :@status
          var_name = ("@"+s.to_s).to_sym
          instance_variable_set( var_name, args[index] )
        end
      end

      attr_reader *status

      # [ presudo code ]
      # def to_yml
      #   hash = [ status1: @status1, status2: @status2 ... ]
      #   return hash.to_yml
      # end
      define_method(:to_yml) do
        instance_vars = instance_variables
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
        datafile_obj = new(*args)
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
        return from_hash(hash)
      end

      # [ presudo code ]
      # def self.from_hash( hash )
      #   return nil if hash[ :status1 ].nil?
      #   @status1 = hash[;status1]
      #
      #   return nil if hash[ :status2 ].nil?
      #   @status2 = hash[;status2]
      #
      #   return nil if hash[ :status3 ].nil?
      #   @status3 = hash[;status3]
      #   ...
      # end
      singleton_class.send( :define_method , :from_hash ) do |hash|
        args = []
        status.each do |s|
          # If there is missing status in hash, fail to generate object and return nil
          return nil if hash[s].nil?
          args.push( hash[s] )
        end
        return new(*args)
      end
    end
  end
end
