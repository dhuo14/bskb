# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
	has_many :params, class_name: :CategoriesParam
	has_many :products
	# 树形结构
  has_ancestry :cache_depth => true
  default_scope -> {order(:ancestry, :sort, :id)}
  
  validates_with MyValidator

  include AboutStatus
  include AboutAncestry

  def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node name='parent_id' data_type='hidden'/>
	    	<node name='品目名称' column='name' class='required' rules='{ remote: { url:"/kobe/categories/valid_name", type:"post" }}'/>
	    </root>
	  }
	end

	def product_xml()
  	arr = []
  	Nokogiri::XML(CategoriesParam.xml).xpath("/root/node[@column]").each{ |node| arr << node.attributes["column"].to_str unless node.attributes["column"].to_str == "id" }
  	doc = Nokogiri::XML::Document.new
    doc.encoding = "UTF-8"
    doc << "<root>"
		self.params.each do |param|
			node = doc.root.add_child("<node>").first
			arr.each do |a|
				next if param[a].blank?
				rule = []
				case a
				when "data"
					node[a] = param[a].split("|") 
				when "is_required"
					rule << "required" if param[a]
				when "rule"
					rule << param[a] unless param[a] == "text"
				else
					node[a] = param[a]
				end
				node["class"] = rule.join(" ") unless rule.blank?
			end
		end
    return doc.to_s
  end

	# 中文意思 状态值 标签颜色 进度 
	def self.status_array
		[
	    ["未提交",0,"orange",10,[1,4,101],[1,0]],
	    ["等待审核",1,"blue",50,[0,4],[3,4]],
	    ["已完成",3,"u",100,[1,4],[3,4]],
	    ["未评价",4,"purple",100,[0,1,101],[3,4]],
	    ["已删除",404,"red",100,[0,1,3,4],nil]
    ]
  end

end
