# -*- encoding : utf-8 -*-
module AboutXml
  # 生成XML表格函数
  # /*options参数说明
  #   title  表单标题 可有可无
  #   grid 每一行显示几个输入框
  # */
  def _show_xml_table(xml,obj,options={})
    grid = options.has_key?("grid") ? options["grid"] : 2
    str = "<div class='panel panel-grey margin-bottom-40'>"
    tbody = ""
    if options.has_key?("title") && !options["title"].blank?
      str << %Q|
      <div class="panel-heading">
          <h3 class="panel-title"><i class="fa fa-info-circle "></i> #{options["title"]}</h3>
      </div>|
    end  
    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='textarea'][@data_type!='richtext']")
    tds.each_slice(grid).with_index do |node,i|
      tbody << "<tr>"
      node.each_with_index{|n,ii|
        tbody << "<td>#{n.attributes["name"]}</td><td>#{_get_column_value(obj,n,{"for_what"=>"table"})}</td>"
        tbody << "<td></td><td></td>" * (grid-ii-1) if (n == node.last) && (ii != grid -1)
      }
      tbody << "</tr>"
    end
    # 再生成文本框和富文本框--针对大文本或者富文本
    doc.xpath("/root/node[contains(@data_type,'text')]").each_slice(1) do |node|
      node.each{|n|
        tbody << "<tr>"
          tbody << "<td>#{n.attributes["name"]}</td><td colspan='#{grid*2-1}'>#{_get_column_value(obj,n)}</td>"
        tbody << "</tr>"
      }
    end

    str << %Q|
      <table class="table table-striped table-bordered">
        <tbody>
          #{tbody}
        </tbody>
      </table>
    </div>|
    return raw str.html_safe
  end

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
    str << "<form class='sky-form' id='#{form_id}' action='#{action}' novalidate='novalidate' method='#{method}'>" 
    str << tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    unless title.blank?
      str << "<header>#{title}</header>"
    end

    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'、'隐藏'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='textarea'][@data_type!='richtext'][@data_type!='hidden']")
    tds.each_slice(grid).with_index do |node,i|
      str << "<fieldset><div class='row'>"
      node.each{|n|
        result = _create_text_field(table_name,_get_column_value(obj,n,{"for_what"=>"form"}),n.attributes,grid)
        str << result[0]
        rules << result[1] unless result[1].blank?
        messages << result[2] unless result[2].blank?
      }
      str << "</div></fieldset>"
    end
    # 再生成文本框和富文本框--针对大文本、富文本或者隐藏域
    doc.xpath("/root/node[@data_type='textarea'] | /root/node[@data_type='richtext'] | /root/node[@data_type='hidden']").each{|n|
      str << "<fieldset><div class='row'>" unless n.attributes["data_type"].to_s == "hidden"
      result = _create_text_field(table_name,_get_column_value(obj,n,{"for_what"=>"form"}),n.attributes,grid)
      str << result[0]
      rules << result[1] unless result[1].blank?
      messages << result[2] unless result[2].blank?
      str << "</div></fieldset>" unless n.attributes["data_type"].to_s == "hidden"
    }

    str << %Q|
      <footer>
          <button class="btn-u" type="submit"><i class="fa fa-floppy-o"></i> 保 存 </button>
          <button class="btn-u btn-u-default" type="reset"><i class="fa fa-repeat"></i> 重 置 </button>
      </footer>|   
    str << %Q|
    <script type="text/javascript">
      var Validation_#{form_id} = function () {
          return {       
              initValidation: function () {
                $('##{form_id}').validate({                   
                  rules:
                  {
                    #{rules.join(",")}
                  },
                  messages:
                  {
                    #{messages.join(",")}
                  },                  
                  errorPlacement: function(error, element)
                  {
                      error.insertAfter(element.parent());
                  }
                });
              }

          };
      }();
      jQuery(document).ready(function() {
          Validation_#{form_id}.initValidation();
      });
    </script>|
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
  def _create_text_field(table_name, value, options={}, grid=1)
    # 没有name和display=skip的直接跳过
    return "" unless options.has_key?("name") && !(options.has_key?("display") && options["display"].to_s == "skip")
    name = options["name"]  
    column = options.has_key?("column") ? options["column"] : name
    icon = options.has_key?("icon") ? options["icon"] : "info"  
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
    # 校验规则
    if options.has_key?("rules") 
      if options["rules"].to_s.include?("required:true")
        name = name.to_s << _red_text("*") 
      end
      rules = "'#{table_name}[#{column}]':#{options["rules"]}"
    end
    # 校验提示消息
    if options.has_key?("messages") 
      messages = "'#{table_name}[#{column}]':'#{options["messages"]}'"
    end

    section = grid == 1 ? "<section>" : "<section class='col col-#{12/grid}'>"

    case data_type
    when "hidden"
      input_str = _create_hidden(table_name,column,value)
    when "radio"
      input_str = _create_radio(section,name,table_name,column,value,opt,hint,data)
    when "checkbox"
      input_str = _create_checkbox(section,name,table_name,column,value,opt,hint,data)
    when "select"
      input_str = _create_select(section,name,table_name,column,value,opt,hint,data)
    when "multiple_select"
      input_str = _create_multiple_select(section,name,table_name,column,value,opt,hint,data)
    when "textarea"
      input_str = _create_textarea(name,table_name,column,value,opt,hint)
    when "richtext"
      input_str = _create_richtext(name,table_name,column,value,opt,hint)
    else
      input_str = _create_text(section,name,table_name,column,value,opt,hint,icon)
    end
    rusult.push(input_str)
    rusult.push(rules)
    rusult.push(messages)
    return rusult
  end

	# 隐藏输入框
  def _create_hidden(table_name,column,value)
    return "<input type='hidden' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' />"
  end
  # 普通文本
  def _create_text(section,name,table_name,column,value,opt,hint,icon)
    str = %Q|
    #{section}
        <label class='label'>#{name}</label>
        <label class='#{_form_states('input',opt)}'>
            <i class="icon-append fa fa-#{icon}"></i>
            <input type='text' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' #{opt.join(" ")}>
            #{hint.blank? ? "" : "<b class='tooltip tooltip-bottom-right'>#{hint}</b>"}
        </label>
    </section>|
  end
  # 单选
  def _create_radio(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('radio',opt) 
    data.each do |d|
      if d.class == Array 
        opt << "checked" if (value && value == d[0])
        data_str << "<label class='#{form_state}'><input type='radio' name='#{table_name}[#{column}]' value='#{d[0]}' #{opt.join(" ")}><i class='rounded-x'></i>#{d[1]}</label>\n"
      else
        opt << "checked" if (value && value == d)
        data_str << "<label class='#{form_state}'><input type='radio' name='#{table_name}[#{column}]' value='#{d}' #{opt.join(" ")}><i class='rounded-x'></i>#{d}</label>\n"
      end
    end
    str = %Q|
    #{section}
        <label class="label">#{name}</label>
        <div class="inline-group">
            #{data_str}
        </div>
        #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }
    </section>|
  end
  # 多选
  def _create_checkbox(section,name,table_name,column,value,opt,hint,data)
    data_str = ""
    form_state = _form_states('checkbox',opt)
    data.each do |d| 
      if d.class == Array
        opt << "checked" if (value && value.split(",").include?(d[0]))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{table_name}[#{column}]' value='#{d[0]}' #{opt.join(" ")}><i></i>#{d[1]}</label>\n"
      else
        opt << "checked" if (value && value.split(",").include?(d))
        data_str << "<label class='#{form_state}'><input type='checkbox' name='#{table_name}[#{column}]' value='#{d}' #{opt.join(" ")}><i></i>#{d}</label>\n"
      end
    end
    str = %Q|
    #{section}
        <label class="label">#{name}</label>
        <div class="inline-group">
            #{data_str}
        </div>
        #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }
    </section>|
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
    #{section}
        <label class='label'>#{name}</label>
        <label class='#{form_state}'>
          <select>
            #{data_str}
          </select>
        </label>
        #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }
    </section>|
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
    #{section}
        <label class='label'>#{name}</label>
        <label class='#{form_state}'>
          <select multiple>
            #{data_str}
          </select>
        </label>
        <div class='note'><strong>提示:</strong> #{hint.blank? ? '按住ctrl键可以多选。' : "#{hint}；按住ctrl键可以多选。" }</div>
    </section>|
  end
  # 大文本
  def _create_textarea(name,table_name,column,value,opt,hint)
  	form_state = _form_states('textarea textarea-resizable',opt)
    str = %Q|
    <section>
        <label class='label'>#{name}</label>
        <label class='#{form_state}'>
            <textarea class='autosize form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' rows='2' #{opt.join(" ")}>#{value}</textarea>
        </label>
        #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }
    </section>|
  end
  # 富文本
  def _create_richtext(name,table_name,column,value,opt,hint)
  	form_state = _form_states('textarea textarea-resizable',opt)
    str = %Q|
    <section>
        <label class='label'>#{name}</label>
        <label class='#{form_state}'>
            <textarea class='autosize form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' rows='2' #{opt.join(" ")}>#{value}</textarea>
        </label>
        #{hint.blank? ? '' : "<div class='note'><strong>提示:</strong> #{hint}</div>" }
    </section>|
  end
  # 样式是否只读
  def _form_states(data_type,opt)
  	return (opt & ["disabled='disabled'","readonly='readonly'"]).empty? ? data_type : "#{data_type} state-disabled"
  end
end