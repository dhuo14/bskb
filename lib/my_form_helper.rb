# -*- encoding : utf-8 -*-
module MyFormHelper

  def create_single_form(myform)
    myform.options[:form_id] ||= "myform" 
    myform.options[:action] ||= "" 
    myform.options[:method] ||= "post"
    myform.options[:grid] ||= 1 
    set_top_part(myform) # 设置FORM头部
    set_input_part(myform) # 设置FORM的主体
    if myform.options.has_key?(:upload_files) && myform.options[:upload_files] == true
      set_upload_part(myform) # 设置上传附件
    else
      set_bottom_part(myform) # 设置底部按钮和JS校验
    end
    content_tag(:div, raw(myform.html_code).html_safe, :class=>'tag-box tag-box-v6')
  end

	def set_top_part(myform)
    myform.html_code << form_tag(myform.options[:action], method: myform.options[:method], class: 'sky-form no-border', id: myform.options[:form_id]).to_str
    unless myform.options[:title].blank?
      myform.html_code << "<h2><strong>#{myform.options[:title]}</strong></h2><hr />"
    end
	end

	def set_input_part(myform)
    doc = Nokogiri::XML(myform.xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'、'隐藏'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='textarea'][@data_type!='richtext'][@data_type!='hidden']")
    tds.each_slice(myform.options[:grid]).with_index do |node,i|
      tmp = ""
      node.each{|n| tmp << _create_text_field(n,myform)}
      myform.html_code << content_tag(:div, raw(tmp).html_safe, :class=>'row')
    end
    # 再生成文本框和富文本框--针对大文本、富文本或者隐藏域
    doc.xpath("/root/node[@data_type='textarea'] | /root/node[@data_type='richtext'] | /root/node[@data_type='hidden']").each{|n|
      unless n.attributes["data_type"].to_s == "hidden"
        myform.html_code << content_tag(:div, raw(_create_text_field(n,myform)).html_safe, :class=>'row')
      else
        myform.html_code << _create_text_field(n,myform)
      end
    }
	end

	def set_upload_part(myform)
		myform.html_code << %Q|
		<input id='#{myform.options[:form_id]}_uploaded_file_ids' name='uploaded_file_ids' type='hidden' />
		</form>|
		# 插入上传组件HTML
		myform.html_code << render(:partial => '/shared/myform/fileupload',:locals => {form_id: myform.options[:form_id],upload_model: myform.obj.class.upload_model, master_id: myform.obj.id, min_number_of_files: myform.options[:min_number_of_files], rules: myform.rules, messages: myform.messages})
	end

	def set_bottom_part(myform)
	  myform.html_code << _create_form_button
    myform.html_code << %Q|
    </form>
    <script type="text/javascript">
      jQuery(document).ready(function() {
        var #{myform.options[:form_id]}_rules = {#{myform.rules.join(",")}};
        var #{myform.options[:form_id]}_messages = {#{myform.messages.join(",")}};
        validate_form_rules('##{myform.options[:form_id]}', #{myform.options[:form_id]}_rules, #{myform.options[:form_id]}_messages);
      });
    </script>|
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
  def _create_text_field(node,myform)
    node_options = node.attributes
    # display=skip的直接跳过
    return "" if node_options.has_key?("display") && node_options["display"].to_s == "skip"
    # 生成输入框
  	node_options = node.attributes
    name = node_options["name"].blank? ? "" : node_options["name"].to_str
    input_opts = {} #传递参数用的哈希
    input_opts[:table_name] = myform.table_name
  	input_opts[:value] = get_node_value(myform.obj,node,{"for_what"=>"form"})
    input_opts[:column] = node_options["column"] || node_options["name"]
  	input_opts[:icon] = get_icon(node_options)
    if node_options.has_key?("data") && !node_options["data"].blank?
      eval("input_opts[:data] = #{node_options["data"]}")
    else
      input_opts[:data] = []
    end 
    # 校验规则
    if node_options.has_key?("rules") 
      if node_options["rules"].to_s.include?("required:true")
        name << _red_text("*") 
      end
      myform.rules << get_node_rules(myform.table_name,myform.obj,node_options)
    end
    # 校验提示消息
    if node_options.has_key?("messages") 
      myform.messages << "'#{input_opts[:table_name]}[#{input_opts[:column]}]':'#{node_options["messages"]}'"
    end
    
    # 没有标注数据类型的默认为字符
    input_opts[:data_type] = node_options.has_key?("data_type") ? node_options["data_type"].to_s : "text"
    input_opts[:hint] = (node_options.has_key?("hint") && !node_options["hint"].blank?) ? node_options["hint"] : ""
    input_opts[:node_attr] = get_node_attr(myform.table_name,node_options)
    input_str = _create_input_str(input_opts)
    if input_opts[:data_type] == "hidden"
      return input_str
    else
      result = "<label class='label'>#{name}</label>#{input_str}"
      if myform.options[:grid].to_i == 1
        return content_tag(:section, raw(result).html_safe)
      else
        if ["textarea","richtext"].include?(input_opts[:data_type])
          section_class = "col col-12"
        else
          section_class = "col col-#{12/myform.options[:grid].to_i}"
        end
        return content_tag(:section, raw(result).html_safe, :class => section_class)
      end
    end
  end

  def _create_input_str(input_opts)
    case input_opts[:data_type]
    when "hidden"
      return _create_hidden(input_opts)
    when "radio"
      return _create_radio(input_opts)
    when "checkbox"
      return _create_checkbox(input_opts)
    when "select"
      return _create_select(input_opts)
    when "multiple_select"
      return _create_multiple_select(input_opts)
    when "textarea"
      return _create_textarea(input_opts)
    when "richtext"
      return _create_richtext(input_opts)
    else
      return _create_text(input_opts)
    end
  end

  def get_icon(node_options)
    unless node_options.has_key?("class")
      default_icon = "info"
    else
      case node_options["class"].to_str
      when "tree_checkbox","tree_radio","box_checkbox","box_radio"
        default_icon = "chevron-down"
      when "date_select"
        default_icon = "calendar"
      end
    end
    return node_options.has_key?("icon") ? node_options["icon"] : default_icon
  end

  def get_node_attr(table_name,node_options)
  	opt = []
  	opt << "disabled='disabled'" if node_options.has_key?("display") && node_options["display"].to_s == "disabled"
    opt << "readonly='readonly'" if node_options.has_key?("display") && node_options["display"].to_s == "readonly"
    opt << "placeholder='#{node_options["placeholder"]}'" if node_options.has_key?("placeholder")
    opt << "class='#{node_options["class"]}'" if node_options.has_key?("class")
    opt << "partner='#{table_name}_#{node_options["partner"]}'" if node_options.has_key?("partner")
    opt << "json_url='#{node_options["json_url"]}'" if node_options.has_key?("json_url")
    opt << "limited='#{node_options["limited"]}'" if node_options.has_key?("limited")
    return opt
  end

  def get_node_rules(table_name,obj,node_options)
    column = node_options["column"] || node_options["name"]
    # 判断有ajax校验的情况，增加当前节点的ID作为判断参数
    if node_options["rules"].to_s.include?("remote")
      hash_rules = eval(node_options["rules"].to_s)
      hash_remote = hash_rules[:remote]
      if hash_remote.has_key?(:data) 
        hash_remote[:data][:obj_id] = obj.id unless obj.id.nil?
      else
        hash_remote[:data] = {obj_id: obj.id} unless obj.id.nil?
      end
      node_options["rules"] = hash_to_string(hash_rules)
    end
    return "'#{table_name}[#{column}]':#{node_options["rules"]}"
  end

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

  # 样式是否只读
  def _form_states(input_style,opt)
    return (opt & ["disabled='disabled'","readonly='readonly'"]).empty? ? input_style : "#{input_style} state-disabled"
  end

# 隐藏输入框
  def _create_hidden(input_opts)
    return "<input type='hidden' id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{input_opts[:value]}' />"
  end
  # 普通文本
  def _create_text(input_opts)
    str = %Q|
    <label class='#{_form_states('input',input_opts[:node_attr])}'>
        <i class="icon-append fa fa-#{input_opts[:icon]}"></i>
        <input type='text' id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{input_opts[:value]}' #{input_opts[:node_attr].join(" ")}>
        #{input_opts[:hint].blank? ? "" : "<b class='tooltip tooltip-bottom-right'>#{input_opts[:hint]}</b>"}
    </label>|
  end
  # 单选
  def _create_radio(input_opts)
    data_str = ""
    form_state = _form_states('radio',input_opts[:node_attr]) 
    input_opts[:data].each do |d|
      options = input_opts[:node_attr].clone
      if d.class == Array 
        options << "checked" if (input_opts[:value] && input_opts[:value] == d[0])
        data_str << "<label class='#{form_state}'><input type='radio' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{d[0]}' #{options.join(" ")}><i class='rounded-x'></i>#{d[1]}</label>\n"
      else
        options << "checked" if (input_opts[:value] && input_opts[:value] == d)
        data_str << "<label class='#{form_state}'><input type='radio' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{d}' #{options.join(" ")}><i class='rounded-x'></i>#{d}</label>\n"
      end
    end
    str = %Q|
    <div class="inline-group">
        #{data_str}
    </div>
    #{input_opts[:hint].blank? ? '' : "<div class='note'><strong>提示:</strong> #{input_opts[:hint]}</div>" }|
  end
  # 多选
  def _create_checkbox(input_opts)
    data_str = ""
    form_state = _form_states('checkbox',input_opts[:node_attr])
    input_opts[:data].each do |d| 
      options = input_opts[:node_attr].clone
      if d.class == Array
        options << "checked" if (input_opts[:value] && input_opts[:value].split(",").include?(d[0]))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{d[0]}' #{options.join(" ")}><i></i>#{d[1]}</label>\n"
      else
        options << "checked" if (input_opts[:value] && input_opts[:value].split(",").include?(d))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' value='#{d}' #{options.join(" ")}><i></i>#{d}</label>\n"
      end
    end
    str = %Q|
    <div class="inline-group">
        #{data_str}
    </div>
    #{input_opts[:hint].blank? ? '' : "<div class='note'><strong>提示:</strong> #{input_opts[:hint]}</div>" }|
  end
  # 下拉单选
  def _create_select(input_opts)
    data_str = ""
    form_state = _form_states('select',input_opts[:node_attr])
    input_opts[:data].each do |d| 
      if d.class == Array
        checked = (input_opts[:value] && input_opts[:value] == d[0]) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d[1]}</option>\n"
      else
        checked = (input_opts[:value] && input_opts[:value] == d) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d}</option>\n"
      end
    end
    str = %Q|
    <label class='#{form_state}'>
      <select id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]'>
        #{data_str}
      </select>
    </label>
    #{input_opts[:hint].blank? ? '' : "<div class='note'><strong>提示:</strong> #{input_opts[:hint]}</div>" }|
  end
  # 下拉多选
  def _create_multiple_select(input_opts)
    data_str = ""
    form_state = _form_states('select select-multiple',input_opts[:node_attr])
    input_opts[:data].each do |d| 
      if d.class == Array
        checked = (input_opts[:value] && input_opts[:value].split(",").include?(d[0])) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d[1]}</option>\n"
      else
        checked = (input_opts[:value] && input_opts[:value].split(",").include?(d)) ? 'checked' : ''
        data_str << "<option value='#{d}' #{checked}>#{d}</option>\n"
      end
    end
    str = %Q|
    <label class='#{form_state}'>
      <select multiple id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]'>
        #{data_str}
      </select>
    </label>
    <div class='note'><strong>提示:</strong> #{input_opts[:hint].blank? ? '按住ctrl键可以多选。' : "#{input_opts[:hint]}；按住ctrl键可以多选。" }</div>|
  end
  # 大文本
  def _create_textarea(input_opts)
    form_state = _form_states('textarea textarea-resizable',input_opts[:node_attr])
    str = %Q|
    <label class='#{form_state}'>
      <textarea class='autosize form-control' id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' rows='2' #{input_opts[:node_attr].join(" ")}>#{input_opts[:value]}</textarea>
    </label>
    #{input_opts[:hint].blank? ? '' : "<div class='note'><strong>提示:</strong> #{input_opts[:hint]}</div>" }|
  end
  # 富文本
  def _create_richtext(input_opts)
    form_state = _form_states('textarea textarea-resizable',input_opts[:node_attr])
    str = %Q|
    <label class='#{form_state}'>
      <textarea class='autosize form-control' id='#{input_opts[:table_name]}_#{input_opts[:column]}' name='#{input_opts[:table_name]}[#{input_opts[:column]}]' rows='2' #{input_opts[:node_attr].join(" ")}>#{input_opts[:value]}</textarea>
    </label>
    #{input_opts[:hint].blank? ? '' : "<div class='note'><strong>提示:</strong> #{input_opts[:hint]}</div>" }|
  end

end