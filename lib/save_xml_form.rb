# -*- encoding : utf-8 -*-
module SaveXmlForm

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
      if for_what == "table"
        result = (result == true) ? "是" : "否"
      elsif for_what == "form"
        result = (result == true) ? 1 : 0
      end
    end
    return result
  end

  #创建并写日志
  def create_and_write_logs(model,other_attrs={})
    attribute = prepare_params_for_save(model,other_attrs)
    attribute["logs"] = get_origin_data(model)
    obj = model.new(attribute)
    if obj.save
      return obj
    else
      return false
    end
  end

  #更新并写日志
  def update_and_write_logs(obj,other_attrs={})
    attribute = prepare_params_for_save(obj.class,other_attrs)
    attribute["logs"] = get_edit_spoor(obj)
    return obj.update(attribute)
  end

  #  手动写入日志 确保表里面有logs和status字段才能用这个函数
  def write_logs(obj,content,remark='')
    doc = prepare_logs_content(obj,content,remark)
    obj.update_columns("logs" => doc)
  end

  # 准备参数，column参数存到字段中，非column参数存到details中,other_attrs 是其他人为赋值字段
  def prepare_params_for_save(model,other_attrs={})
    tmp = get_xmlform_params(model)
    result = tmp[0]
    unless tmp[1].blank?
      result["details"] = prepare_details(tmp[1]) if model.attribute_method?(:details)
      result["parent_id"] = tmp[1]["parent_id"] if tmp[1].has_key?("parent_id")
    end
    other_attrs.each{|key,value|
      result[key] = value
    }
    return result
  end

  # 批量操作要替换的日志
  def batch_logs(status,content,remark='来自批量操作')
    return %Q|<node 操作时间="#{Time.new.to_s(:db)}" 操作人ID="#{current_user.id}" 操作人姓名="#{current_user.name}" 操作人单位="#{current_user.department.nil? ? "暂无" : current_user.department.name}" 操作内容="#{content}" 当前状态="#{status}" 备注="#{remark}" IP地址="#{request.remote_ip}[#{IPParse.parse(request.remote_ip).gsub("Unknown", "未知")}]"/></root>|
  end

private

  #XML_FORM表单提交后生成的参数，返回二维数组，第一维是存入数据库的column参数，第二维是拼成details的name参数
  def get_xmlform_params(model,who='',options={})
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
    return [params.require(model.to_s.tableize.to_sym).permit(column_params) ,params.require(model.to_s.tableize.to_sym).permit(name_params)]
  end

  #根据XML_FORM表单提交后的参数准备好details的XML文档
  def prepare_details(data)
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

  # 准备日志的内容
  def prepare_logs_content(obj,content,remark='')
    user = current_user
    unless obj.logs.nil?
      doc = Nokogiri::XML(obj.logs)
    else
      doc = Nokogiri::XML::Document.new()
      doc.encoding = "UTF-8"
      doc << "<root>"
    end
    node = doc.root.add_child("<node>").first
    node["操作时间"] = Time.now.to_s(:db)
    node["操作人ID"] = user.id.to_s
    node["操作人姓名"] = user.name.to_s
    node["操作人单位"] = user.department.nil? ? "暂无" : user.department.name.to_s
    node["操作内容"] = content
    node["当前状态"] = (!obj.attribute_names.include?("status") || obj.status.nil?) ? "-" : obj.status
    node["备注"] = remark
    node["IP地址"] = "#{request.remote_ip}|#{IPParse.parse(request.remote_ip).gsub("Unknown", "未知")}"
    return doc.to_s
  end

  # 获取创建时的原始数据
  def get_origin_data(model)
    spoor = ""
    doc = Nokogiri::XML(model.xml)
    all_params = params.require(model.to_s.tableize.to_sym)
    doc.xpath("/root/node").each{|node|
      attr_name = node.attributes["name"].to_str
      if node.attributes.has_key?("column")
        new_value = all_params[node.attributes["column"].to_str]
      else
        new_value = all_params[node.attributes["name"].to_str]
      end 
      spoor << "<tr><td>#{attr_name}</td><td>#{new_value}</td></tr>" unless new_value.to_s.blank?
    }
    remark = %Q|<font class='view_logs_detail'>详细信息</font><div class='logs_detail'><table class='table table-bordered'><thead><tr><th>参数名称</th><th>参数值</th></tr></thead><tbody>#{spoor}</tbody></table></div>|.html_safe
    return prepare_logs_content(model.new,"录入数据",remark)
  end

  # 获取修改痕迹
  def get_edit_spoor(obj)
    model = obj.class
    spoor = ""
    doc = Nokogiri::XML(model.xml)
    all_params = params.require(model.to_s.tableize.to_sym)
    doc.xpath("/root/node").each{|node|
      attr_name = node.attributes["name"].to_str
      if node.attributes.has_key?("column")
        new_value = all_params[node.attributes["column"].to_str]
      else
        new_value = all_params[node.attributes["name"].to_str]
      end 
      old_value = get_node_value(obj,node,{"for_what"=>"table"})
      spoor << "<tr><td>#{attr_name}</td><td>#{old_value}</td><td>#{new_value}</td></tr>" unless old_value.to_s == new_value.to_s
    }
    remark = %Q|<font class='view_logs_detail'>修改痕迹</font><div class='logs_detail'><table class='table table-bordered'><thead><tr><th>参数名称</th><th>修改前</th><th>修改后</th></tr></thead><tbody>#{spoor}</tbody></table></div>|.html_safe
    return prepare_logs_content(obj,"修改数据",remark)
  end

end