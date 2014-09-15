# -*- encoding : utf-8 -*-
module XmlFormHelper
  include AboutXml

  # 红色标记的文本，例如必填项*
  def _red_text(txt)
    return raw "<span class='text-red'>#{txt}</span>".html_safe
  end

  # 获取某实例的字段值
  def _get_column_value(obj,node,options={})
    result = ""
    details_column = options.has_key?("details_column") ? options["details_column"] : "details"
    if node.attributes.has_key?("column") && obj.class.attribute_method?(node["column"])
      result = obj[node["column"]]
    else
      if obj.class.attribute_method?(details_column) && obj[details_column]
        doc = Nokogiri::XML(obj[details_column])
        tmp = doc.xpath("/root/node[@name='#{node["name"]}']").first
        result = tmp.blank? ? "" : tmp["value"]
      end
    end
    # 对布尔型的值转换
    if result == true || result == false
      for_what = options.has_key?("for_what") ? options["for_what"] : "table"
      if for_what == "table"
        result = (result == true) ? "是" : "否"
      elsif for_what == "form"
        result = (result == true) ? 1 : 0
      end
    end
    return result
  end

end