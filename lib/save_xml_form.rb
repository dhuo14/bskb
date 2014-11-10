# -*- encoding : utf-8 -*-
module SaveXmlForm

  include BaseFunction

  # 创建主从表并写日志
  def create_msform_and_write_logs(master,slave,other_attrs={})
    master_obj = create_and_write_logs(master,other_attrs)
    slave_params = params.require(slave.to_s.tableize.to_sym)
    column_name = get_column_and_name_array(slave)
    
    # 参数的高度即slava的数量,预设必须有ID这个参数
    slave_objs = []
    slave_params["id"].keys.each do |i|
      attribute = {"details" => {}}
      column_name[0].each{|column| attribute[column] = slave_params[column][i]}
      column_name[1].each{|name| attribute["details"][name] = slave_params[name][i]}
      if attribute["id"].blank?
        attribute["#{master.to_s.underscore}_id"] = master_obj.id #主键
        attribute.delete("id")
        attribute["details"] = prepare_details(attribute["details"])
        slave.create(attribute)
      else
        obj = slave.find(attribute["id"])
        obj.update_attributes(attribute)
      end
    end
  end

  #创建并写日志
  def create_and_write_logs(model,other_attrs={})
    attribute = prepare_params_for_save(model,other_attrs)
    attribute["logs"] = get_origin_data(model)
    obj = model.new(attribute)
    if obj.save
      unless params["uploaded_file_ids"].blank?
        uploads = model.upload_model.where(master_id: 0, id: params["uploaded_file_ids"].split(","))
        obj.uploads << uploads
      end
      return obj
    else
      return false
    end
  end

  #更新并写日志
  def update_and_write_logs(obj,other_attrs={})
    attribute = prepare_params_for_save(obj.class,other_attrs)
    attribute["logs"] = get_edit_spoor(obj)
    return obj.update_attributes(attribute)
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
  def batch_logs(content,remark='来自批量操作')
    return %Q|<node 操作时间="#{Time.new.to_s(:db)}" 操作人ID="#{current_user.id}" 操作人姓名="#{current_user.name}" 操作人单位="#{current_user.department.nil? ? "暂无" : current_user.department.name}" 操作内容="#{content}" 当前状态="$STATUS$" 备注="#{remark}" IP地址="#{request.remote_ip}[#{IPParse.parse(request.remote_ip).gsub("Unknown", "未知")}]"/>|
  end

private

  #XML_FORM表单提交后生成的参数，返回二维数组，第一维是存入数据库的column参数，第二维是拼成details的name参数
  def get_xmlform_params(model,who='',options={})
    tmp = get_column_and_name_array(model,who,options)
    return [params.require(model.to_s.tableize.to_sym).permit(tmp[0]) ,params.require(model.to_s.tableize.to_sym).permit(tmp[1])]
  end

  # 返回二维数组，第一维是存入数据库的column参数，第二维是拼成details的name参数
  def get_column_and_name_array(model,who='',options={})
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
    return [column_params,name_params]
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
      attr_name = node.attributes.has_key?("name") ? node.attributes["name"] : node.attributes["column"]
      if node.attributes.has_key?("column")
        new_value = all_params[node.attributes["column"].to_str]
      else
        new_value = all_params[node.attributes["name"].to_str]
      end 
      new_value = transform_boolean(new_value,"table") if attr_name.to_str.index("是否") == 0
      spoor << "<tr><td>#{attr_name.to_str}</td><td>#{new_value}</td></tr>" unless new_value.to_s.blank?
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
      attr_name = node.attributes.has_key?("name") ? node.attributes["name"] : node.attributes["column"]
      if node.attributes.has_key?("column")
        new_value = all_params[node.attributes["column"].to_str]
      else
        new_value = all_params[node.attributes["name"].to_str]
      end 
      new_value = transform_boolean(new_value,"table") if attr_name.to_str.index("是否") == 0
      old_value = get_node_value(obj,node,{"for_what"=>"table"})
      spoor << "<tr><td>#{attr_name.to_str}</td><td>#{old_value}</td><td>#{new_value}</td></tr>" unless old_value.to_s == new_value.to_s || new_value.nil?
    }
    remark = %Q|<font class='view_logs_detail'>修改痕迹</font><div class='logs_detail'><table class='table table-bordered'><thead><tr><th>参数名称</th><th>修改前</th><th>修改后</th></tr></thead><tbody>#{spoor}</tbody></table></div>|.html_safe
    return prepare_logs_content(obj,"修改数据",remark)
  end

end