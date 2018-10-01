@pwd=File.dirname(__FILE__)
Dir.chdir(@pwd+"/../")
require 'mib-parser'
require 'pp'
include Mib
file=NodeDB::MIB_FILE_PATH + "/" + 'FTPSERVER-MIB.mib'
parser=Parser.new(file)
#pp parser.get_node
pp parser.get_node("microsoft")
