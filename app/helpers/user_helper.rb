# -*- encoding : utf-8 -*-
module UserHelper

	# arr = [
	# 	{ "icon" => "fa-bar-chart-o", "title" => "Overall" },
	# 	{ 
	# 		"icon" => "fa-group", "title" => "单位信息", 
	# 		"status" => current_user.department.org_code.blank?,
	# 		"url" => kobe_department_path(current_user.department)
	# 	},
	# 	{ "icon" => "fa-list", "title" => "证件扫描件" },
	# 	{ "icon" => "fa-cubes", "title" => "资质证书" },
	# 	{ 
	# 		"icon" => "fa-user", "title" => "用户信息", 
	# 		"status" => current_user.name.blank?, 
	# 		"url" => kobe_user_path(current_user),
	# 		"opt" => current_user.cando_list
	# 	}
	# ]
	# 
	# 左侧菜单 
	def left_bar(arr,act=0)
		str = %Q{
			<div class="col-md-3 md-margin-bottom-40">
				<ul class="list-group sidebar-nav-v1 margin-bottom-40">
		}
		arr.each_with_index do |ha,index|
			str << left_bar_li(ha,index,act)
		end
		str << "</ul></div>"
		return raw str.html_safe
	end

	def left_bar_li(ha,index,act)
		click = ha["url"].blank? ? "javascript:void(0)" : "show_content('#{ha["url"]}','##{index}_tab .show_content')"
		str = %Q{
			<li class="list-group-item#{index == act.to_i ? ' active' : ''}">
			#{ha["status"] ? '<span class="label label-yellow badge">未完成</span>' : ''}
				<a href="##{index}_tab" data-toggle="tab" onClick="#{click}">
					<i class="fa #{ha["icon"]}"></i> #{ha["title"]}
				</a>
			</li>
		}
		return raw str.html_safe
	end

	# 右侧展示
	def show_content(arr,act=0)
		str = %Q{
		<div class="profile col-md-9">
			<div class="profile-body">
				<div class="tab-content">
		}
		arr.each_with_index do |ha,index|
			str << show_tab(ha,index,act)
		end
		str << %Q{
				</div>
			</div>
		</div>
		}
		return raw str.html_safe
	end

	def show_tab(ha,index=0,act=0)
		str = %Q{	
			<div class="profile-edit tab-pane fade#{index == act.to_i ? ' active in' : ''}" id="#{index}_tab">
				<div class="panel-heading overflow-h">
					<h2 class="panel-title heading-sm pull-left">
					<i class="fa #{ha["icon"]}"></i> #{ha["title"]}
					</h2>
					<div class='pull-right'>
						#{btn_group(ha["opt"],false) unless ha["opt"].blank?}
					</div>
				</div>
				<div class="show_content">
				</div>
			</div>
		}
	end

	# ajax加载页面 适用于首次加载页面或页面跳转返回指定页面
	def ajax_show_content(url,div)
		str = %Q{
			<script type="text/javascript">
				$(document).ready(function(){
    			show_content('#{url}','#{div}')
  			});
			</script>
		}
		return raw str.html_safe
	end

	def user_profile(arr,act=0)
		str = left_bar(arr,act)
		str << show_content(arr,act)
		str << ajax_show_content(arr[act.to_i]["url"],"##{act}_tab .show_content")
		return raw str.html_safe
	end

	# 弹框
	def dialog(div_id,content,title='提示')
		str = %Q{
			<div aria-hidden="true" aria-labelledby="myModalLabel" role="dialog" tabindex="-1" id="#{div_id}" class="modal fade" style="display: none;">
		    <div class="modal-dialog">
	        <div class="modal-content">
			      <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
			        <h4 class="modal-title" id="myModalLabel">#{title}</h4>
			      </div>
    }
    str << content
    str << %Q{
	        </div>
		    </div>
			</div>
		}
		return raw str.html_safe
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
		return dialog(div_id,str,ha["title"])
	end
	# 提示框
	def tips_dialog(div_id,msg)
		return dialog(div_id,msg)
	end

	# 生成含有登录名、密码、确认密码的div 用于注册、分配人员账号、重置密码
	def create_user_login_password_div
		str = %Q{
			<section>
				<label class="label">登录名 <span class="color-red">*</span></label>
				<label class="input">
					<i class="icon-append fa fa-user"></i>
					<input type="text" name="user[login]" id="user_login" placeholder="登录名" />
					<b class="tooltip tooltip-bottom-right">长度为6-20个字符，不能是中文</b>
				</label>
			</section>

			<div class="row">
				<section class="col col-6">
					<label class="label">密码 <span class="color-red">*</span></label>
					<label class="input">
						<i class="icon-append fa fa-lock"></i>
						<input type="password" name="user[password]" id="user_password" placeholder="密码" />
						<b class="tooltip tooltip-bottom-right">长度为6-20个字符</b>
					</label>
				</section>

				<section class="col col-6">
					<label class="label">确认密码 <span class="color-red">*</span></label>
					<label class="input">
						<i class="icon-append fa fa-lock"></i>
						<input type="password" name="user[password_confirmation]" id="user_password_confirmation" placeholder="确认密码" />
					</label>
				</section>
			</div>
		}
		return raw str.html_safe
	end

	# 生成含有操作理由的div 用于冻结单位时填写操作理由
	def create_op_liyou_div(input_name='opt_liyou')
		str = %Q{
			<section>
				<label class="label">操作理由 <span class="color-red">*</span></label>
				<label class="input">
					<i class="icon-append fa fa-pencil"></i>
					<input type="text" name="#{input_name}" id="#{input_name}" placeholder="操作理由" />
				</label>
			</section>
		}
		return raw str.html_safe
	end

	# def show_xml_tab(xml,obj,options={})
 #    grid = options.has_key?("grid") ? options["grid"] : 2
 #    str = %Q|
 #    <div class='tab-v2'>
 #      <ul class='nav nav-tabs'>
 #        <li class='active'><a data-toggle='tab' href='#info-#{obj.id.to_s}'><i class="fa fa-info-circle"></i> 详细信息</a></li>
 #        <li class=''><a data-toggle='tab' href='#logs-#{obj.id.to_s}'><i class="fa fa-clock-o"></i> 历史记录</a></li>
 #      </ul>                
 #      <div class='tab-content'>
 #        <div id='info-#{obj.id.to_s}' class='tab-pane fade in active'>|
 #    tbody = ""
 #    if options.has_key?("title") && !options["title"].blank?
 #      str << %Q|
 #      <div class="panel-heading">
 #          <h3>#{options["title"]}</h3>
 #      </div>|
 #    else
 #      str << "<br />"
 #    end  
 #    doc = Nokogiri::XML(xml)
 #    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
 #    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='hidden'][@data_type!='textarea'][@data_type!='richtext']")
 #    tds.each_slice(grid).with_index do |node,i|
 #      tbody << "<tr>"
 #      node.each_with_index{|n,ii|
 #        tbody << "<td>#{n.attributes["name"]}</td><td>#{get_node_value(obj,n,{"for_what"=>"table"})}</td>"
 #        tbody << "<td></td><td></td>" * (grid-ii-1) if (n == node.last) && (ii != grid -1)
 #      }
 #      tbody << "</tr>"
 #    end
 #    # 再生成文本框和富文本框--针对大文本或者富文本
 #    doc.xpath("/root/node[contains(@data_type,'text')]").each_slice(1) do |node|
 #      node.each{|n|
 #        tbody << "<tr>"
 #          tbody << "<td>#{n.attributes["name"]}</td><td colspan='#{grid*2-1}'>#{get_node_value(obj,n)}</td>"
 #        tbody << "</tr>"
 #      }
 #    end

 #    str << %Q|
 #          <table class="table table-striped table-bordered">
 #            <tbody>
 #              #{tbody}
 #            </tbody>
 #          </table>
 #        </div>
 #        <div id='logs-#{obj.id.to_s}' class='tab-pane fade in'>
 #          #{show_logs(obj)}
 #        </div>
 #      </div>
 #    </div>|
 #    return raw str.html_safe
 #  end

 #  def show_xml_tab_info(xml,obj,options={})
 #  	str = ""
 #  	tbody = ""
 #    if options.has_key?("title") && !options["title"].blank?
 #      str << %Q|
 #      <div class="panel-heading">
 #          <h3>#{options["title"]}</h3>
 #      </div>|
 #    else
 #      str << "<br />"
 #    end  
 #    doc = Nokogiri::XML(xml)
 #    # 先生成输入框--针对没有data_type属性或者data_type属性不包括'大文本'、'富文本'的
 #    tds = doc.xpath("/root/node[not(@data_type)] | /root/node[@data_type!='hidden'][@data_type!='textarea'][@data_type!='richtext']")
 #    tds.each_slice(grid).with_index do |node,i|
 #      tbody << "<tr>"
 #      node.each_with_index{|n,ii|
 #        tbody << "<td>#{n.attributes["name"]}</td><td>#{get_node_value(obj,n,{"for_what"=>"table"})}</td>"
 #        tbody << "<td></td><td></td>" * (grid-ii-1) if (n == node.last) && (ii != grid -1)
 #      }
 #      tbody << "</tr>"
 #    end
 #    # 再生成文本框和富文本框--针对大文本或者富文本
 #    doc.xpath("/root/node[contains(@data_type,'text')]").each_slice(1) do |node|
 #      node.each{|n|
 #        tbody << "<tr>"
 #          tbody << "<td>#{n.attributes["name"]}</td><td colspan='#{grid*2-1}'>#{get_node_value(obj,n)}</td>"
 #        tbody << "</tr>"
 #      }
 #    end

 #    str << %Q{
	#       <table class="table table-striped table-bordered">
	#         <tbody>
	#           #{tbody}
	#         </tbody>
	#       </table>
	#   }
 #  	return raw str.html_safe
 #  end
end