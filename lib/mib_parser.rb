#/bin/ruby
module Mib
    class Node
        attr_accessor :name,:type,:syntax,:syntax_map,:parent,:local_id,:entry_index,:oid;
        def initialize(name)
            @name=name
        end
        def oid
            if @oid.nil?
                @oid=self.parent
                @oid << "." + self.local_id.to_s if self.local_id.to_s.length > 0
            end
            @oid
	end
        def oid=(value)
            if value.is_a?(String)
                oid_list=value.split(/\s+/)
                if oid_list.length==2
                   self.parent=oid_list[0]
                   self.local_id = oid_list[1]
                end
                oid_list.collect!{|v| v=~/[\w-]+\(\d+)/ ? $1 : v}
                value = oid_list.join(".")
            end
            @oid=value
        end
        def syntax=(value)
            if value.downcase == "rawstatus"
               @syntax_map={
                    "createAndGo"=> "4",
                    "destroy"    => "6"
               }
            end
            @syntax=value
        end
        def syntax_map=(value)
            if value.is_a?(String)
               maps={}
               value.scan(/([\w-]+)\s*([\d-])/){|kv|                
                   maps[k]=v
               }
               @syntax_map=maps
            else
               @syntax_map=value
            end
        end 
        def update_oid(mibdb)
            oid_list=self.oid.split(".")
	    parent_node=mibdb[oid_list[0]]
            if self.name == self.parent
               puts "Node info is not correct"
               return
            end
	    if parent_node
                parent_oid=parent_node.update_oid(mibdb)
                oid_list[0]=parent_oid
                @oid=oid_list.join(".")
            end
            @oid
	end

    end
    class Table
    end
    class MibDB < Hash
        def initialize
            super
            self["iso"]=Node.new("iso")
            self["iso"].oid="1"
        end
        def <<(node)
            self[node.name]=node
	end
        def update_oid
            self.each {|name, node|
                node.update_oid(self)
            }
        end
    end
    class Parser
         def initialize(mibfile)
             @nodes=NodeDB.new
             @file=mibfile
             File.open(mibfile) {|file| @content=file.read}
             @nodes.update_oid
         end
         def parse_mib_file
             type_pattern = NODE_TYPE.join("|")
             node_pattern = /^\s*(\S+)\s+#{type_pattern}\s*(.*?)\s*::=\s*\{(.*?)\}/m
             self.parse_module_name
             self.parse_imports
             @content.scan(node_pattern){|nodeinfo|
                 node      =Node.new(nodeinfo[0})
                 @nodes    << node
                 node.type = nodeinfo[1]
                 node.oid  = nodeinfo[3]
                 self.parse_node_info(nodeinfo[2], node)
             }
         end
         def parse_module_name
             module_pattern = /(\S+)\s+DEFINITION\s*::=\s*BEGIN/
             if @content =~ module_pattern
                 @module=$1
                 @content=$'
             end
         end
         def parse_imports
             imports_pattern = /(\S+)\s+DEFINITION\s*::=\s*BEGIN/
             if @content =~ imports_pattern
                 @module=$1
                 @content=$'
             end
         end
         def parse_node_info(content, node_obj)
             if content =~ /SYNTAX\s+(\S+)\s*(?=\{\})\s*$/m
                 node_obj.syntax=$1.strip
                 node_obj.syntax_map=$2.strip if $2
             end
             if content =~ /MAX-ACCESS\s+(\S+)/
                 node_obj.max_access=$1.strip
             end
             if content =~ /DESCRIPTION\s+"(.*?)"/m
                 node_obj.description=$1.gsub(/^\s*--.*$/, "")
             end
             if content =~ /INDEX\s*\{(.*?)\}/m
                 node_obj.index=$1.strip
             end
             if content =~ /STATUS\s+(\S+)/
                 node_obj.status=$1.strip
             end
         end
    end
end

require "pp"
file=''
mibparser=Mib::Parser.new(file)
pp mibparser.nodes
