# -*- encoding : utf-8 -*-
module SaveXmlForm

  # column参数存到字段中，非column参数存到details中,others 是其他人为赋值字段
  def xml_form_params(model,others={})
    tmp = get_xml_params(model)
    result = tmp[0]
    unless tmp[1].blank?
      result["details"] = create_xml_data(tmp[1]) if model.attribute_method?(:details)
      result["parent_id"] = tmp[1]["parent_id"] if tmp[1].has_key?("parent_id")
    end
    others.each{|key,value|
      result[key] = value
    }
    return result
  end

  #XML_FORM表单提交后生成的参数
  def get_xml_params(model,who='',options={})
    column_params = []
    name_params = []
    doc = Nokogiri::XML(model.xml(who,options))
    doc.xpath("/root/node").each{|node|
      if node.attributes.has_key?("column")
        column_params << node.attributes["column"].to_s
      else
        name_params << node.attributes["name"].to_s
      end
    }
    if options.has_key?("type") && options["type"] == "name"
      return params.require(model.to_s.tableize.to_sym).permit(name_params) 
    elsif options.has_key?("type") && options["type"] == "column"
      return params.require(model.to_s.tableize.to_sym).permit(column_params) 
    else
      return [params.require(model.to_s.tableize.to_sym).permit(column_params) ,params.require(model.to_s.tableize.to_sym).permit(name_params)]
    end
  end

 #XML_FORM表单提交后保存时的XML文档
 def create_xml_data(data)
    doc = Nokogiri::XML::Document.new
    doc.encoding = "UTF-8"
    doc << "<root>"
    data.each do |key,value|
      next if ["parent_id","父节点名称"].include?(key)
      node = doc.root.add_child("<node>").first
      node["name"] = key
      node["value"] = value
    end
    return doc.to_s
 end
end