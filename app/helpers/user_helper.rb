# -*- encoding : utf-8 -*-
module UserHelper

	def render_html(partial_path, locals = {})
	  raw render(partial: partial_path, locals: locals).html_safe
	end

	# 页面提示信息(不是弹框) 
	# cls_name = { 'alert-warning', 'alert-danger', 'alert-success', 'alert-info' }
	def show_tips(cls_name,alert_title='',msg='',opt='')		
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
		str << %Q{ <p>#{opt}</p> } unless opt.blank?
		str << %Q{ </div> }
		return raw str.html_safe
	end


	# 弹框 
	# 按钮要有href="#div_id" data-toggle="modal"
	# 例如<a class="btn btn-sm btn-default" href="#div_id" data-toggle="modal">
	def alert_dialog(div_id,content,title='提示')
		raw render_html('/shared/dialog/modal_dialog', div_id: div_id, content: content, title: title).html_safe
	end

	# 多个标签的展示页面
	def show_tab(obj,arr=[])
		if arr.blank?
			arr = [
				{"div_id" => "info-#{obj.id.to_s}", "icon" => "fa-info-circle", "title" => "详细信息", "content" => show_xml_info(obj.class.xml,obj)}, 
				{"div_id" => "logs-#{obj.id.to_s}", "icon" => "fa-clock-o", "title" => "历史记录", "content" => show_logs(obj)}
			]
		end
		str = %Q{
			<div class='tab-v2'>
				#{show_tab_ul(arr)}
			<div class='tab-content'>
		}
		arr.each_with_index { |ha,index| str << show_tab_content(ha["div_id"],ha["content"],index) }
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
			icon = ha["icon"].blank? ? "" : " #{ha["icon"]}"
			str << %Q{
	        <li#{index == 0 ? " class='active'" : ""}><a data-toggle='tab' href='##{ha["div_id"]}'><i class='fa#{icon}'></i> #{ha["title"]}</a></li>
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

    str << %Q{
    	<table class="table table-striped table-bordered">
        <tbody>
          #{tbody}
        </tbody>
      </table>
    }
		return raw str.html_safe
	end

end