# -*- encoding : utf-8 -*-
class SingleForm
	attr_accessor :options, :rules, :messages, :html_code
	attr_reader :xml, :obj

	def initialize(xml,obj,options={})
		@xml = xml
		@obj = obj
		@options = options
		@rules = []
		@messages = []
		@html_code = ""
	end

	def table_name
		obj.class.to_s.tableize
	end

end