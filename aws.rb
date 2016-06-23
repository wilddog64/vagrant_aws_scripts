require 'pathname'
require 'pp'
class Aws

  # constructor
  def initialize( credential_file_path = '~/.aws', profile='dreambox-dev' )

    config_profile = "profile #{profile}"
    # get aws config files
    credential_file = File.join( File.expand_path( credential_file_path ), 'credentials' )
    config_file     = File.join( File.expand_path( credential_file_path ), 'config' )

    # read two ini files into their own hash and then merge them into one
    aws_config = parse_inifile( config_file )
    aws_cred   = parse_inifile( credential_file )
    config     = aws_config[config_profile].merge( aws_cred[profile] )

    realize_object( config )
  end

  private

  def realize_object( config = nil )
    # here, we want to generate read accessor automatically so we do need to
    # write tedous accessors ourself. refer to this
    # http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/
    # for detail
    config.each do | key, val |
       self.instance_variable_set( "@#{key}", val )
       self.class.send( :define_method, key, proc { self.instance_variable_get( "@#{key}" ) } )
    end
  end

  # parse_inifile will read and parse an ini file to return it as a hash table back
  # to caller.  This function accepts one parameter,
  #
  #  inifile_path is a valid path point to where ini file stored.  Default value is nil
  #
  # It is caller's responsiblity to ensure file exists and path is a valid path.
  def parse_inifile( inifile_path = nil )

    fh       = File.open( inifile_path )  # open an ini file to read
    ini_hash = {}                         # create a hash bucket to store key, value pairs
    key      = nil                        # hash key
    fh.each_line do | line |  # eumerate each line to find out information
      line.strip!             # strip leading and trailing white spaces
      next if ( line =~ /^#/ )
      line.gsub!( /\s*#.*$/, '' )
      if ( line =~ /^\[(.*?)\]/ )
        key           = $1
        ini_hash[key] = {}
      elsif ( line =~ /(.*?)\s*=\s*([^=].*?)$/ )
        ini_hash[key][$1] = $2
      end
    end

    ini_hash
  end
end
