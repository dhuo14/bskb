# -*- encoding : utf-8 -*-
module MyFormHelper
  include BaseFunction

  def draw_myform(myform)
    set_top_part(myform) # 设置FORM头部
    set_input_part(myform) #设置主表input
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
      myform.html_code << "<div class='headline'><h2><strong>#{myform.options[:title]}</strong></h2></div>"
    end
	end

	def set_input_part(myform)
    myform.html_code << myform.get_input_part
	end

	def set_upload_part(myform)
		myform.html_code << %Q|
		<input id='#{myform.options[:form_id]}_uploaded_file_ids' name='uploaded_file_ids' type='hidden' />
		</form>|
		# 插入上传组件HTML
		myform.html_code << render(:partial => '/shared/myform/fileupload',:locals => {a: "ddd", myform: myform})
	end

	def set_bottom_part(myform)
	  myform.html_code << myform.get_form_button
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

  def get_button_part(myform,self_form=true)
    myform.get_form_button(self_form)
  end

  # 显示页面
  # 生成XML表格函数
  # /*options参数说明
  #   title  表单标题 可有可无
  #   grid 每一行显示几个输入框
  # */
  def _show_xml_table(xml,obj,options={})
    grid = options.has_key?("grid") ? options["grid"] : 2
    str = %Q|
    <div class='tab-v2'>
      <ul class='nav nav-tabs'>
        <li class='active'><a data-toggle='tab' href='#info-#{obj.id.to_s}'><i class="fa fa-info-circle"></i> 详细信息</a></li>
        <li class=''><a data-toggle='tab' href='#logs-#{obj.id.to_s}'><i class="fa fa-clock-o"></i> 历史记录</a></li>
      </ul>                
      <div class='tab-content'>
        <div id='info-#{obj.id.to_s}' class='tab-pane fade in active'>|
    tbody = ""
    if options.has_key?("title") && !options["title"].blank?
      str << %Q|
      <div class="panel-heading">
          <h3>#{options["title"]}</h3>
      </div>|
    else
      str << "<br />"
    end  
    doc = Nokogiri::XML(xml)
    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='hidden'][@data_type!='textarea'][@data_type!='richtext']")
    tds.each_slice(grid).with_index do |node,i|
      tbody << "<tr>"
      node.each_with_index{|n,ii|
        tbody << "<td>#{n.attributes["name"]}</td><td>#{get_node_value(obj,n,{"for_what"=>"table"})}</td>"
        tbody << "<td></td><td></td>" * (grid-ii-1) if (n == node.last) && (ii != grid -1)
      }
      tbody << "</tr>"
    end
    # 再生成文本框和富文本框--针对大文本或者富文本
    doc.xpath("/root/node[contains(@data_type,'text')]").each_slice(1) do |node|
      node.each{|n|
        tbody << "<tr>"
          tbody << "<td>#{n.attributes["name"]}</td><td colspan='#{grid*2-1}'>#{get_node_value(obj,n)}</td>"
        tbody << "</tr>"
      }
    end

    str << %Q|
          <table class="table table-striped table-bordered">
            <tbody>
              #{tbody}
            </tbody>
          </table>
        </div>
        <div id='logs-#{obj.id.to_s}' class='tab-pane fade in'>
          #{show_logs(obj)}
        </div>
      </div>
    </div>|
    return raw str.html_safe
  end
	
end