@pwd=File.dirname(File.expand_path(__FILE__))
Dir.chdir(@pwd+"/../")
require 'mib-parser'
require 'pp'
include Mib
require 'test/unit'

class Parser_Test < Test::Unit::TestCase
    @pwd=File.dirname(File.expand_path(__FILE__))
    testfile= @pwd + "/test/MY_TEST-MIB.mib"
    @@parser=Parser.new(testfile)
    def test_parser_fun
        assert_equal(false, @@parser.nil?)
    end
    def test_file
        assert_equal("MY_TEST-MIB.mib", @@parser.file)
    end
    def test_module_name
        assert_equal("MY_TEST-MIB", @@parser.module)
    end
    def test_imports
        assert_equal(Hash, @@parser.imports.class)
        assert_equal(true, @@parser.imports.has_key?("SNMPv2-SMI"))
        assert_equal(["enterprises"], @@parser.imports["SNMPv2-SMI"])
    end
    def test_get_name1
        assert_equal(false, @@parser.get_node.nil?)
    end
    def test_get_node2
        assert_equal(Node, @@parser.get_node.values[0].class)
    end
end
