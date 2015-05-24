#!/usr/bin/env ruby
$LOAD_PATH.unshift( File.expand_path( File.dirname( __FILE__ ) ) )

require 'aws.rb'
require 'pp'

aws_creds = Aws.new( '~/.aws', 'mgmt' )
puts "export access_key_id=#{aws_creds.aws_access_key_id}"
puts "export secret_access_key=#{aws_creds.aws_secret_access_key}"
puts "export aws_region=#{aws_creds.region}"
puts "export AWS_ACCESS_KEY_ID=#{aws_creds.aws_access_key_id}"
puts "export AWS_SECRET_ACCESS_KEY=#{aws_creds.aws_secret_access_key}"
