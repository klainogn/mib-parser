module Mib
    class NodeDB < Hash
        MIB_DB_PATH = File.dirname(__FILE__)+"/gencode_db"
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
        def gen_code(module_name)
            file=File.open(MIB_DB_PATH + "/" + module_name + ".rb", "w+")
            code="module Mib\n"
            self.each {|name, node|
                if node.module == module_name
                    code << "@nodeDB << Node.new('#{name}i')\n"      
                    node.instance_variables.each {|var|
                         code << "@nodeDB['#{name}'].#{var.sub("@", "")} = '#{node.instance_eval(var)}'\n" 
                    }
                end 
            }
           code << "end"
           file.write(code)
        end
        def load_module(module_name)
            module_file=MIB_DB_PATH + "/" + module_name + ".rb"
            begin
                #load module_file
            rescue Exception e
                puts e          
            end
        end
    end
end
