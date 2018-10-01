@pwd=File.dirname(__FILE__)
Dir.chdir(@pwd + "/../")
require "mib-parser"
require "pp"
include Mib
class NodeDB
    def self.get_db
        @@node_db
    end
end
pp NodeDB.get_db
NodeDB.load_module("FTPSERVER-MIB")
pp NodeDB.get_db

