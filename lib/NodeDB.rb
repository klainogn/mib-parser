module Mib
    class NodeDB
        MIB_DB_PATH = File.dirname(__FILE__)+"/gencode_db"
        MIB_FILE_PATH = File.dirname(__FILE__) + "/../mibs"
        @@node_db={}
        @@node_db["iso"]=Node.new("iso")
        @@node_db["iso"].oid="1"
        def self.<<(node)
            @@node_db[node.name]=node
	end
        def self.update_oid
            @@node_db.each {|name, node|
                node.update_oid(@@node_db)
            }
        end
        def self.[](name)
            @@node_db[name]
        end
        def self.gen_code(module_name)
            file=File.open(MIB_DB_PATH + "/" + module_name + ".rb", "w+")
            code="module Mib\n"
            @@node_db.each {|name, node|
                if node.module == module_name
                    code << "    node = Node.new('#{name}')\n"      
                    node.instance_variables.each {|var|
                         code << "    node.#{var.sub("@", "")} = '#{node.instance_eval(var)}'\n" 
                    }
                    code << "    NodeDB << node\n\n"
                end 
            }
           code << "end"
           file.write(code)
        end
        def self.load_module(module_name)
            module_db_file=MIB_DB_PATH + "/" + module_name + ".rb"
            begin
                require module_db_file 
            rescue Exception=> e
                module_mib_file=MIB_FILE_PATH + "/" + module_name + ".mib"
                if FileTest.exist?(module_mib_file)
                    mib_parser= Parser.new(module_mib_file)
                    self.gen_code(mib_parser.module)
                else
                    puts e          
                end
            end
        end
        def self.get_nodes_by_module(module_name)
            nodes={}
            @@node_db.each{|name, node|
               nodes[name] = node if node.module == module_name
            }
            return nodes
        end
    end
end
