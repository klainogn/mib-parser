module Mib
    NODE_TYPE=[
        "OBJECT IDENTIFIER",
        "OBJECT-TYPE"
    ]
    class Node
        attr_accessor :name,:type,:syntax,:syntax_map,:description,:parent,:local_id;
        attr_accessor :status,:entry_index,:oid,:module;
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
                oid_list.collect!{|v| v=~/[\w-]+\((\d+)\)/ ? $1 : v}
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
end 
