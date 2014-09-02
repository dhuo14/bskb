# -*- encoding : utf-8 -*-
module XmlFormHelper

  # 红色标记的文本，例如必填项*
  def _red_text(txt)
    return raw "<span class='text-red'>#{txt}</span>".html_safe
  end

  # 获取某实例的字段值
  def _get_column_value(obj,node,details_column='details')
    if node.attributes.has_key?("column") && obj.class.attribute_method?(node["column"])
      return obj[node["column"]]
    else
      if obj.class.attribute_method?(details_column) && obj[details_column]
        doc = Nokogiri::XML(obj[details_column])
        tmp = doc.xpath("/root/node[@name='#{node["name"]}']").first
        return tmp.blank? ? "" : tmp["value"]
      else
        return ""
      end
    end
  end

  # 生成XML表单函数
  # /*options参数说明
  #   form_id 表单ID
  #   button_id 按钮ID,与自定义的validate_js配合使用
  #   validate_js 表单自定义验证JS
  #   action 提交的路径
  #   title  表单标题 可有可无
  #   grid 每一行显示几个输入框
  #   only_show 在shouw/audit等只需要显示内容的页面设为true，则自动去除form,input,button等标签 
  # */
  def _create_xml_form(xml,obj,options={})
    table_name = obj.class.to_s.tableize
    form_id = options.has_key?("form_id") ? options["form_id"] : "myform" 
    button_id = options.has_key?("button_id") ? options["button_id"] : "mybutton"
    action = options.has_key?("action") ? options["action"] : "" 
    title = options.has_key?("title") ? options["title"] : "" 
    grid = options.has_key?("grid") ? options["grid"] : 1 
    only_show = options.has_key?("only_show") ? options["only_show"] : false 
    str = "<div class='row'><div class='box col-sm-12'>"
    unless title.blank?
      str << "<div class='box-header'><div class='title'>#{title}</div><div class='actions'><a href='#'' class='btn box-remove btn-xs btn-link'><i class='icon-remove'></i></a><a href='#'' class='btn box-collapse btn-xs btn-link'><i></i></a></div></div>"
    end
    unless only_show
      str << "<form class='form form-horizontal validate-form' id='#{form_id}' action='#{action}' style='margin-bottom: 0;' method='post'>" 
      str << tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end
    str << "<div class='box-content box-no-padding'>"
    str << "<table style='margin-bottom:0;' class='table table-bordered'>"
    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='大文本'][@data_type!='富文本']")
    tds.each_slice(grid).with_index do |node,i|
      str << "<tr>"
      node.each_with_index{|n,ii|
        if i * grid + ii + 1 == tds.length
          rest = grid - (ii + 1)
        else 
          rest = 0
        end
        str << _create_text_field(table_name,_get_column_value(obj,n),n.attributes,only_show,rest)
      }
      str << "</tr>"
    end
    # 再生成文本框和富文本框--针对大文本或者富文本
    doc.xpath("/root/node[contains(@data_type,'文本')]").each_slice(1) do |node|
      str << "<tr>"
      node.each{|n|str << _create_text_field(table_name,_get_column_value(obj,n),n.attributes,only_show,grid-1)}
      str << "</tr>"
    end
    str << "</table>"
    str << "</div>"
    unless only_show 
      str << "<div style='padding:15px;'><button id='#{button_id}'class='btn btn-primary' type='submit'><i class='icon-save'></i> 保 存 </button></div></form>"
    end   
    str << "</div>"
    str << options["validate_js"] if options.has_key?("validate_js") 
    return raw str.html_safe
  end
  
  # 生成输入框函数
  # /*options参数说明
  #   name  标签名称
  #   column 字段名称，有column时数据会存入相应的字段，没有时会以XML的形式存入detail字段中
  #   data_type 数据类型，字符、数字、日期、时间、日期时间、IP、URL、EMAIL、布尔、普通单选、普通多选、树形单选、树形多选等。配合验证JS使用
  #   minlength 允许输入最少的字符数
  #   maxlngth 允许输入最多的字符数，默认是127
  #   hint 提示信息，点击?会弹出提示框，一般比较复杂的事项、流程提醒等
  #   placeholder 输入框内提示信息
  #   required 是否必填，为true 会有小红星*
  #   display 显示方式 disabled 不可操作 readonly 是否只读 skip 跳过不出现 hidden 隐藏
  #   rest 每行剩余的空白单元格
  #   
  # # */
  def _create_text_field(table_name, value, options={}, only_show=false,rest=0)
    # 没有name和display=skip的直接跳过
    return "" unless options.has_key?("name") && !(options.has_key?("display") && options["display"].to_s == "skip")
    name = options["name"]  
    column = options.has_key?("column") ? options["column"] : name 
    if only_show 
      input_str = "<pre>#{value}</pre>"  # 仅仅显示的话不生成输入框
    else 
      input_str = ""
      # 隐藏标签，一般是通过JS来赋值
      if options.has_key?("display") && options["display"].to_s == "hidden"
        return "<input type='hidden' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' />"
      end
      # 没有标注数据类型的默认为字符
      data_type = options.has_key?("data_type") ? options["data_type"].to_s : "字符"
      unless options.has_key?("maxlength")
        options["maxlength"] = ["大文本","富文本"].include?(data_type) ? '8000' : '127' 
      end
      hint = options.has_key?("hint") ? "<span class='icon-question-sign has-popover' data-title='提示' data-placement='right' data-content='#{options["hint"]}'></span>" : ""
      opt = []
      opt << "disabled='disabled'" if options.has_key?("display") && options["display"].to_s == "disabled"
      opt << "readonly='readonly'" if options.has_key?("display") && options["display"].to_s == "readonly"
      opt << "placeholder='#{options["placeholder"]}'" if options.has_key?("placeholder")
      opt << "data-rule-minlength='#{options["minlength"]}'" if options.has_key?("minlength")
      opt << "data-rule-maxlength='#{options["maxlength"]}'" if options.has_key?("maxlength")
      if options.has_key?("required") && options["required"].to_s == 'true'
        opt << "data-rule-required='true'"
        red_start = _red_text("*") 
      else
        red_start = ""
      end
      case data_type
      when "大文本"
        input_str = "<textarea class='autosize form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' rows='2' #{opt.join(" ")}>#{value}</textarea>"
      when "富文本"
        input_str = "<textarea class='autosize form-control' rows='4'>#{value}</textarea>"
      when "数字"
        opt <<  "data-rule-digits='true'"
      when "日期"
        opt <<  "data-rule-dateiso='true'"
      when "IP"
        opt <<  "data-rule-ipv4='true'"
      when "email"
        opt <<  "data-rule-email='true'"
      when "URL"
        opt <<  "data-rule-url='true'"
      end
      input_str = "<input type='text' class='form-control' id='#{table_name}_#{column}' name='#{table_name}[#{column}]' value='#{value}' #{opt.join(" ")}>" if input_str.blank?
    end
    if ["大文本","富文本"].include?(data_type)
          str = "<td class='form-group'><div class='control-label'><label for='#{column}'>#{red_start} #{name} #{hint}</label></div></td><td class='controls' colspan='#{rest*2+1}'>#{input_str}</td>"
    else
      str = "<td class='form-group'><div class='control-label'><label for='#{column}'>#{red_start} #{name} #{hint}</label></div></td><td class='controls'>#{input_str}</td>"
      rest.times { str << "<td></td><td></td>" }
    end
    return str
  end

end