#! /usr/bin/env ruby

require 'rubygems'
require 'xmpp4r'
require 'optparse'

options = {}

optparse = OptionParser.new do|opts|

  script_name = File.basename($0)

  opts.banner = "Usage: #{script_name} [options] ..."

  opts.on( '-n', '--node HOSTNAME', 'Single node to check' ) do |hostname|
    options[:hostname] = hostname
  end

  opts.on( '-j', '--jid JID','JID of account to test' ) do |jid|
    options[:jid] = jid
  end

  opts.on( '-p', '--password PASSWORD') do|password|
    options[:password] = password
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

begin
  optparse.parse!
  mandatory = [:jid, :password]
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

unless options[:hostname]
  options[:hostname] = options[:jid].split("@")[1]
end

begin
  client_jid = Jabber::JID.new(options[:jid])
  client = Jabber::Client.new(client_jid)
  client.connect(options[:hostname])
  client.auth(options[:password])
  client.close
  puts "Ejabberd is up on #{options[:hostname]}"
rescue
  puts "Ejabberd DOWN on #{options[:hostname]}"
  raise SystemExit.new(2)
end
