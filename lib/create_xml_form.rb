# -*- encoding : utf-8 -*-
module CreateXmlForm
  
  # 生成XML表单函数
  # /*options参数说明
  #   form_id 表单ID
  #   validate_js 表单自定义验证JS
  #   action 提交的路径
  #   title  表单标题 可有可无
  #   grid 每一行显示几个输入框
  # */
  def _create_xml_form(xml,obj,options={})
    table_name = obj.class.to_s.tableize
    form_id = options.has_key?("form_id") ? options["form_id"] : "myform" 
    action = options.has_key?("action") ? options["action"] : "" 
    method = options.has_key?("method") ? options["method"] : "post"
    title = options.has_key?("title") ? options["title"] : "" 
    grid = options.has_key?("grid") ? options["grid"] : 1 
    str = ""
    rules = []
    messages = []
    str = "<div class='tag-box tag-box-v6'>"
    str << form_tag(action, method: method, class: 'sky-form no-border', id: form_id).to_str
    unless title.blank?
      str << "<h2><strong>#{title}</strong></h2><hr />"
    end
    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'、'隐藏'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='textarea'][@data_type!='richtext'][@data_type!='hidden']")
    tds.each_slice(grid).with_index do |node,i|
      str << "<div class='row'>"
      node.each{|n|
        result = _create_text_field(table_name,obj,n,grid)
        str << result[0]
        rules << result[1] unless result[1].blank?
        messages << result[2] unless result[2].blank?
      }
      str << "</div>"
    end
    # 再生成文本框和富文本框--针对大文本、富文本或者隐藏域
    doc.xpath("/root/node[@data_type='textarea'] | /root/node[@data_type='richtext'] | /root/node[@data_type='hidden']").each{|n|
      str << "<div class='row'>" unless n.attributes["data_type"].to_s == "hidden"
      result = _create_text_field(table_name,obj,n,grid)
      str << result[0]
      rules << result[1] unless result[1].blank?
      messages << result[2] unless result[2].blank?
      str << "</div>" unless n.attributes["data_type"].to_s == "hidden"
    }
    # 如果需要上传附件
    if options.has_key?("upload_files") && options["upload_files"] == true
      str << %Q|
        <input id='#{form_id}_uploaded_file_ids' name='uploaded_file_ids' type='hidden' />
        </form>|
      # 插入上传组件HTML
      str << render(:partial => '/shared/myform/fileupload',:locals => {form_id: form_id,upload_model: obj.class.upload_model, master_id: obj.id, min_number_of_files: options["min_number_of_files"], rules: rules, messages: messages})
    else
      str << _create_form_button
      str << %Q|
      </form>
      <script type="text/javascript">
        jQuery(document).ready(function() {
          var #{form_id}_rules = {#{rules.join(",")}};
          var #{form_id}_messages = {#{messages.join(",")}};
          validate_form_rules('##{form_id}', #{form_id}_rules, #{form_id}_messages);
        });
      </script>|
    end
    str << "</div>"
    return raw str.html_safe
  end
  
  # 生成输入框函数
  # /*options参数说明
  #   name  标签名称
  #   column 字段名称，有column时数据会存入相应的字段，没有时会以XML的形式存入detail字段中
  #   data_type 数据类型
  #   hint 提示信息，点击?会弹出提示框，一般比较复杂的事项、流程提醒等
  #   placeholder 输入框内提示信息
  #   display 显示方式 disabled 不可操作 readonly 是否只读 skip 跳过不出现
  #   
  # # */
  def _create_text_field(table_name, obj, node, grid=1)
    options = node.attributes
    # display=skip的直接跳过
    return "" if options.has_key?("display") && options["display"].to_s == "skip"
    value = get_node_value(obj,node,{"for_what"=>"form"})
    name = options["name"]  
    column = options.has_key?("column") ? options["column"] : name
    unless options.has_key?("class")
      default_icon = "info"
    else
      case options["class"].to_str
      when "tree_checkbox","tree_radio","box_checkbox","box_radio"
        default_icon = "chevron-down"
      when "date_select"
        default_icon = "calendar"
      end
    end
    icon = options.has_key?("icon") ? options["icon"] : default_icon  
    if options.has_key?("data") && !options["data"].blank?
      eval("data = #{options["data"]}")
    else
      data = []
    end 
    input_str = ""
    rules = ""
    messages = ""
    rusult = []
    
    # 没有标注数据类型的默认为字符
    data_type = options.has_key?("data_type") ? options["data_type"].to_s : "text"
    hint = (options.has_key?("hint") && !options["hint"].blank?) ? options["hint"] : ""
    opt = []
    opt << "disabled='disabled'" if options.has_key?("display") && options["display"].to_s == "disabled"
    opt << "readonly='readonly'" if options.has_key?("display") && options["display"].to_s == "readonly"
    opt << "placeholder='#{options["placeholder"]}'" if options.has_key?("placeholder")
    opt << "class='#{options["class"]}'" if options.has_key?("class")
    opt << "partner='#{table_name}_#{options["partner"]}'" if options.has_key?("partner")
    opt << "json_url='#{options["json_url"]}'" if options.has_key?("json_url")
    opt << "limited='#{options["limited"]}'" if options.has_key?("limited")
    # 校验规则
    if options.has_key?("rules") 
      if options["rules"].to_s.include?("required:true")
        name = name.to_s << _red_text("*") 
      end
      # 判断有ajax校验的情况，增加当前节点的ID作为判断参数
      if options["rules"].to_s.include?("remote")
        hash_rules = eval(options["rules"].to_s)
        hash_remote = hash_rules[:remote]
        if hash_remote.has_key?(:data) 
          hash_remote[:data][:obj_id] = obj.id unless obj.id.nil?
        else
          hash_remote[:data] = {obj_id: obj.id} unless obj.id.nil?
        end
        options["rules"] = hash_to_string(hash_rules)
      end
      rules = "'#{table_name}[#{column}]':#{options["rules"]}"
      
    end
    # 校验提示消息
    if options.has_key?("messages") 
      messages = "'#{table_name}[#{column}]':'#{options["messages"]}'"
    end
    # 生成输入框
    input_str = _create_input_str(grid,data_type,name,table_name,column,value,opt,hint,data,icon)
    rusult.push(input_str)
    rusult.push(rules)
    rusult.push(messages)
    return rusult
  end

  # 样式是否只读
  def _form_states(data_type,opt)
  	return (opt & ["disabled='disabled'","readonly='readonly'"]).empty? ? data_type : "#{data_type} state-disabled"
  end

  def show_logs(obj)
    return "暂无记录" if obj.logs.blank?
    icons = Dictionary.icons
    str = []
    doc = Nokogiri::XML(obj.logs)
    doc.xpath("/root/node").each do |n|
      opt_time = n.attributes["操作时间"].to_s.split(" ")
      act = n.attributes["操作内容"].to_s[0,2]
      icon = icons.has_key?(act) ? icons[act] : icons["其他"]
      infobar = []
      infobar << "状态:#{obj.status_badge(n.attributes["当前状态"].to_s.to_i)}" if n.attributes.has_key?("当前状态")
      infobar << "姓名:#{n.attributes["操作人姓名"]}"
      infobar << "ID:#{n.attributes["操作人ID"]}"
      infobar << "单位:#{n.attributes["操作人单位"]}"
      infobar << "IP地址:#{n.attributes["IP地址"]}"
      str << %Q|
      <li>
        <time class='cbp_tmtime' datetime=''><span>#{opt_time[1]}</span> <span>#{opt_time[0]}</span></time>
      <i class='cbp_tmicon rounded-x hidden-xs'></i>
        <div class='cbp_tmlabel'>
          <h2><i class="fa #{icon}"></i> #{n.attributes["操作内容"]}</h2>
          <p>#{n.attributes["备注"]}</p>
          <p>#{infobar.join("&nbsp;&nbsp;")}</p>
        </div>
      </li>|
    end
    return "<ul class='timeline-v2'>#{str.reverse.join}</ul>"
  end

# 生成表单框begin
  
  # 生成提交按钮
  def _create_form_button(id=nil)
    id = id.nil? ? "" : " id='#{id}'"
    %Q|
    <hr />
    <div>
      <button#{id} class="btn-u btn-u-lg" type="submit"><i class="fa fa-floppy-o"></i> 保 存 </button>
      <button#{id} class="btn-u btn-u-lg btn-u-default" type="reset"><i class="fa fa-repeat"></i> 重 置 </button>
    </div>|
  end

  def _create_input_str(grid,data_type,name,table_name,column,value,opt,hint,data,icon)
    if data_type == "hidden"
      return _create_hidden(table_name,column,value) 
    else
      if ["textarea","richtext"].include?(data_type)
        section = grid == 1 ? "<section>" : "<section class='col col-12'>"
      else
        section = grid == 1 ? "<section>" : "<section class='col col-#{12/grid}'>"
      end
      case data_type
      when "radio"
        input_str = _create_radio(section,name,table_name,column,value,opt,hint,data)
      when "checkbox"
        input_str = _create_checkbox(section,name,table_name,column,value,opt,hint,data)
      when "select"
        input_str = _create_select(section,name,table_name,column,value,opt,hint,data)
      when "multiple_select"
        input_str = _create_multiple_select(section,name,table_name,column,value,opt,hint,data)
      when "textarea"
        input_str = _create_textarea(section,name,table_name,column,value,opt,hint)
      when "richtext"
        input_str = _create_richtext(section,name,table_name,column,value,opt,hint)
      else
        input_str = _create_text(section,name,table_name,column,value,opt,hint,icon)
      end
      return "#{section}<label class='label'>#{name}</label>#{input_str}</section>"
    end
  end


# 隐藏输入框
  def _create_hidden(table_name,column,value)
    return "<input type='hidden' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' />"
  end
  # 普通文本
  def _create_text(section,name,table_name,column,value,opt,hint,icon)
    str = %Q|
    <label class='#{_form_states('input',opt)}'>
        <i class="icon-append fa fa-#{icon}"></i>
        <input type='text' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' #{opt.join(" ")}>
        #{hint.blank? ? "" : "<b class='tooltip tooltip-bottom-right'>#{hint}</b>"}
    </label>|
  end
  # 单选
  def _create_radio(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('radio',opt) 
    data.each do |d|
      options = opt.clone
      if d.class == Array 
        options << "checked" if (value && value == d[0])
        data_str << "<label class='#{form_state}'><input type='radio' name='#{table_name}[#{column}]' value='#{d[0]}' #{options.join(" ")}><i class='rounded-x'></i>#{d[1]}</label>\n"
      else
        options << "checked" if (value && value == d)
        data_str << "<label class='#{form_state}'><input type='radio' name='#{table_name}[#{column}]' value='#{d}' #{options.join(" ")}><i class='rounded-x'></i>#{d}</label>\n"
      end
    end
    str = %Q|
    <div class="inline-group">
        #{data_str}
    </div>
    #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }|
  end
  # 多选
  def _create_checkbox(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('checkbox',opt)
    data.each do |d| 
      options = opt.clone
      if d.class == Array
        options << "checked" if (value && value.split(",").include?(d[0]))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{table_name}[#{column}]' value='#{d[0]}' #{options.join(" ")}><i></i>#{d[1]}</label>\n"
      else
        options << "checked" if (value && value.split(",").include?(d))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{table_name}[#{column}]' value='#{d}' #{options.join(" ")}><i></i>#{d}</label>\n"
      end
    end
    str = %Q|
    <div class="inline-group">
        #{data_str}
    </div>
    #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }|
  end
  # 下拉单选
  def _create_select(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('select',opt)
    data.each do |d| 
      if d.class == Array
        checked = (value && value == d[0]) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d[1]}</option>\n"
      else
        checked = (value && value == d) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d}</option>\n"
      end
    end
    str = %Q|
    <label class='#{form_state}'>
      <select>
        #{data_str}
      </select>
    </label>
    #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }|
  end
  # 下拉多选
  def _create_multiple_select(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('select select-multiple',opt)
    data.each do |d| 
      if d.class == Array
        checked = (value && value.split(",").include?(d[0])) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d[1]}</option>\n"
      else
        checked = (value && value.split(",").include?(d)) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d}</option>\n"
      end
    end
    str = %Q|
    <label class='#{form_state}'>
      <select multiple>
        #{data_str}
      </select>
    </label>
    <div class='note'><strong>提示:</strong> #{hint.blank? ? '按住ctrl键可以多选。' : "#{hint}；按住ctrl键可以多选。" }</div>|
  end
  # 大文本
  def _create_textarea(section,name,table_name,column,value,opt,hint)
    form_state = _form_states('textarea textarea-resizable',opt)
    str = %Q|
    <label class='#{form_state}'>
      <textarea class='autosize form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' rows='2' #{opt.join(" ")}>#{value}</textarea>
    </label>
    #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }|
  end
  # 富文本
  def _create_richtext(section,name,table_name,column,value,opt,hint)
    form_state = _form_states('textarea textarea-resizable',opt)
    str = %Q|
    <label class='#{form_state}'>
      <textarea class='autosize form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' rows='2' #{opt.join(" ")}>#{value}</textarea>
    </label>
    #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }|
  end

end