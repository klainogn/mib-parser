module Mib
   class Parser
         attr_accessor :file, :nodes, :module
         def initialize(mibfile)
             @file=File.basename(mibfile)
             File.open(mibfile) {|file| @content=file.read}
             parse_mib_file
             load_modules
             NodeDB.update_oid
             @nodes=NodeDB.get_nodes_by_module(@module)
         end
         def parse_mib_file
             type_pattern = NODE_TYPE.join("|")
             node_pattern = /^\s*(\S+)\s+(#{type_pattern})\s*(.*?)\s*::=\s*\{\s*(.*?)\s*\}/m
             self.parse_module_name
             self.parse_exports
             self.parse_imports
             @content.scan(node_pattern){|nodeinfo|
                 node      =Node.new(nodeinfo[0].strip)
                 NodeDB    << node
                 node.module = @module
                 node.type = nodeinfo[1].strip
                 node.oid  = nodeinfo[3].strip
                 self.parse_node_info(nodeinfo[2].strip, node)
             }
         end
         def parse_module_name
             module_pattern = /(\S+)\s+DEFINITIONS\s*::=\s*BEGIN/
             if @content =~ module_pattern
                 @module=$1
                 @content=$'
             end
         end
         def parse_exports
             exports_pattern = /EXPORTS\s*(.*?);/m
             if @content =~ exports_pattern
                 @exports=$1.strip.split(/\s*,\s*/)
             end
         end
         def parse_imports
             imports_pattern = /IMPORTS\s+(.*?);/m
             if @content =~ imports_pattern
                 @content    = $'
                 @imports    = {}
                 import_info = $1
                 import_info.scan(/(.*?)\s+FROM\s+(\S+)/) {|import|
                     @imports[import[1]]=import[0].split(/\s*,\s*/) 
                 }
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
                 node_obj.description=$1.gsub(/^\s*--.*$|^\s+/, "")
             end
             if content =~ /INDEX\s*\{(.*?)\}/m
                 node_obj.entry_index=$1.strip
             end
             if content =~ /STATUS\s+(\S+)/
                 node_obj.status=$1.strip
             end
         end
         def get_node(name=nil)
             if name.nil?
                @nodes
             else
                NodeDB[name]
             end
         end
         def load_modules
             @imports.keys.each {|mod_name|
                 NodeDB.load_module(mod_name.to_s)
             } if @imports
         end
         def gen_code
             NodeDB.gen_code(@module)
         end
    end
end
