# -*- encoding : utf-8 -*-
class MasterSlaveForm < MyForm

	attr_accessor :options, :slave_options, :rules, :messages, :html_code
	attr_reader :xml, :slave_xml, :obj, :slave_objs, :table_name, :slave_table_name

	def initialize(master_xml,slave_xml,obj,slave_objs,master_options={},slave_options={})
		@xml = master_xml
		@slave_xml = slave_xml
		@obj = obj
		@slave_objs = slave_objs
		@options = master_options
		@slave_options = slave_options
		@table_name = obj.class.to_s.tableize
		@slave_table_name = slave_objs[0].class.to_s.tableize
		@rules = []
		@messages = []
		@html_code = ""
		@options[:grid] ||= 2 
		@options[:form_id] ||= "myform" 
    @options[:action] ||= "" 
    @options[:method] ||= "post"
		@slave_options[:grid] ||= 4 
	end

	def get_slave_input_part
  	tmp = ""
  	slave_objs.each_with_index{|o,i|
  		tmp << "<div class='panel panel-grey'><div class='panel-heading'><h3 class='panel-title'><i class='fa fa-tasks'></i> #{i+1} 删除</h3></div><div class='panel-body'>"
  		tmp << self.get_input_str(slave_xml,o,slave_table_name,slave_options[:grid])
  		tmp << "</div></div>"
  	}
  	return tmp
  end

end