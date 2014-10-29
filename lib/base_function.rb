# -*- encoding : utf-8 -*-
module BaseFunction

# 获取某实例的字段值
def get_node_value(obj,node,options={})
    # 父节点特殊处理
    if obj.attributes.include?("ancestry")
    	return obj.parent_id if node["name"] == "parent_id" 
    	return obj.parent_name if node["name"] == "父节点名称"
    end
    # 一般情况
    result = ""
    if node.attributes.has_key?("column") && obj.class.attribute_method?(node["column"])
    	result = obj[node["column"]]
    else
    	if obj.class.attribute_method?("details") && !obj["details"].blank?
    		doc = Nokogiri::XML(obj["details"])
    		tmp = doc.xpath("/root/node[@name='#{node["name"]}']").first
    		result = tmp.blank? ? "" : tmp["value"]
    	end
    end
    # 对布尔型的值转换
    if result == true || result == false
    	for_what = options.has_key?("for_what") ? options["for_what"] : "table"
    	result = transform_boolean(result,for_what)
    end
    return result
  end

  #布尔型转换
  def transform_boolean(s,for_what)
  	return s unless [true,false,1,0,'1','0','是','否'].include?(s)
  	if for_what == "table"
  		return (s == true || s.to_s == "1") ? "是" : "否"
  	elsif for_what == "form"
  		return (s == true || s.to_s == "是") ? 1 : 0
  	end
  end

  # 哈希转成syml格式的字符串，供JS调用
  def hash_to_string(ha)
  	if ha.class == Hash
  		arr = []
  		ha.each do |key,value|
  			arr << "#{key}:#{hash_to_string(value)}"
  		end
  		return "{#{arr.join(',')}}"
  	elsif ha.class == String
  		return "'#{ha}'"
  	else
  		return ha
  	end
  end

end