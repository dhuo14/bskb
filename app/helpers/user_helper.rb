# -*- encoding : utf-8 -*-
module UserHelper

	# render partial的Helper方法 
	def render_html(partial_path, locals = {})
	  raw render(partial: partial_path, locals: locals).html_safe
	end

	# 页面提示信息(不是弹框) 
	def show_tips(type,alert_title='',msg='')
		cls_name = ""
		case type
		when "info"
			cls_name = 'alert-info'
		when "error"
			cls_name = 'alert-danger'
		when "tips"
			cls_name = 'alert-success'
		when "warning"
			cls_name = 'alert-warning'
		end
		str =%Q{
			<div class="alert #{cls_name} fade in">
				<button class="close" aria-hidden="true" data-dismiss="alert" type="button">×</button>
				<h4>#{alert_title}</h4>
		}
		if msg.class == Array
			msg.each{ |m| str << %Q{ <p>#{m}</p> } }
		else
			str << %Q{ <p>#{msg}</p> }
		end
		str << %Q{ </div> }
		return raw str.html_safe
	end

	# modal弹框 
	# 按钮要有href="#div_id" data-toggle="modal"
	# 例如<a class="btn btn-sm btn-default" href="#div_id" data-toggle="modal">
	def modal_dialog(div_id='modal_dialog',content='',title='提示')
		raw render_html('/shared/dialog/modal_dialog', div_id: div_id, content: content, title: title).html_safe
	end

	# 多个标签的展示页面
	def show_tab(obj,arr=[])
		if arr.blank?
			arr = [{ div_id: "info-#{obj.id.to_s}", icon: "fa-info-circle", title: "详细信息", content: show_xml_info(obj.class.xml,obj) }, {div_id: "logs-#{obj.id.to_s}", icon: "fa-clock-o", title: "历史记录", content: show_logs(obj)}]
		end
		str = %Q{
			<div class='tab-v2'>
				#{show_tab_ul(arr)}
			<div class='tab-content'>
		}
		arr.each_with_index { |ha,index| str << show_tab_content(ha[:div_id],ha[:content],index) }
		str << %Q{
			</div>
		</div>
		}
    return raw str.html_safe
	end

	# 标签
	def show_tab_ul(arr=[])
		str = %Q{
			<ul class='nav nav-tabs'>
		}
		arr.each_with_index do |ha,index|
			icon = ha[:icon].blank? ? "" : " #{ha[:icon]}"
			str << %Q{
	        <li#{index == 0 ? " class='active'" : ""}><a data-toggle='tab' href='##{ha[:div_id]}'><i class='fa#{icon}'></i> #{ha[:title]}</a></li>
	    }
	  end
    str << "</ul>"
		return raw str.html_safe
	end

	# 每一个tab展示的内容
	def show_tab_content(div_id,content,act=0)
		str = %Q{
			<div id='#{div_id}' class='tab-pane fade in#{act == 0 ? " active" : ""}'>
				#{content}
			</div>
		}
    return raw str.html_safe
	end

	# 根据XML生成show页面的table
	def show_xml_info(xml,obj,options={})
		grid = options.has_key?("grid") ? options["grid"] : 2
		str = ""
		tbody = ""
    if options.has_key?(:title) && !options[:title].blank?
      str << %Q|
      <div class="panel-heading">
          <h3>#{options[:title]}</h3>
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

    str << %Q{
    	<table class="table table-striped table-bordered">
        <tbody>
          #{tbody}
        </tbody>
      </table>
    }
		return raw str.html_safe
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
          <h2><i class="fa fa-chevron-circle-right"></i> #{n.attributes["操作内容"]} <i class="fa #{icon}"></i></h2>
          <div style="display:none;">#{n.attributes["备注"]}</div>
          <p>#{infobar.join("&nbsp;&nbsp;")}</p>
        </div>
      </li>|
    end
    return "<ul class='timeline-v2'>#{str.reverse.join}</ul>"
  end

end