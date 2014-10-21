# -*- encoding : utf-8 -*-
module UserHelper

	def render_html(partial_path, locals = {})
	  render partial: partial_path, locals: locals
	end

	# 弹框 
	# 按钮要有href="#div_id" data-toggle="modal"
	# 例如<a class="btn btn-sm btn-default" href="#div_id" data-toggle="modal">
	def alert_dialog(div_id,content,title='提示')
		return render_html('/share/modal_dialog', div_id: div_id, content: content, title: title)
	end

	# 确认弹框
	# ha = {"action" => "", "method" => "", "div_id" => "", "title" => "", "content" => ""}
	def confirm_dialog(ha)
  	action = ha.has_key?("action") ? ha["action"] : "" 
  	method = ha.has_key?("method") ? ha["method"] : "post"
  	div_id = ha.has_key?("div_id") ? ha["div_id"] : ""
  	str = form_tag(action, method: method, class: 'sky-form', id: "#{div_id}_form").to_str
    str << %Q{
      <div class="modal-body">
			#{ha["content"]}
      </div>
	    <div class="modal-footer">
	      <button type="button" class="btn-u btn-u-default" data-dismiss="modal">取消</button>
	      <button type="submit" class="btn-u">确定</button>
	    </div>
	    </form>
	    }
		return alert_dialog(div_id,str,ha["title"])
	end

	# 生成含有操作理由的div 用于冻结单位时填写操作理由
	def create_op_liyou_div(input_name='opt_liyou')
		return render_html('/share/opt_liyou', input_name: input_name)
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
		}
		str << show_tab_ul(arr)
		str << %Q{
			<div class='tab-content'>
		}
		arr.each_with_index do |ha,index|
			str << show_tab_content(ha["div_id"],ha["content"],index)
		end
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