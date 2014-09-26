# -*- encoding : utf-8 -*-
module UserHelper

	# ha = {
	# 	"main" => { "icon" => "fa-bar-chart-o", "title" => "Overall" },
	# 	"dep" => { 
	# 		"icon" => "fa-group", "title" => "单位信息", 
	# 		"status" => current_user.department.org_code.blank?,
	# 		"url" => kobe_department_path(current_user.department)
	# 	},
	# 	"photo" => { "icon" => "fa-list", "title" => "证件扫描件" },
	# 	"zizhi" => { "icon" => "fa-cubes", "title" => "资质证书" },
	# 	"user" => { 
	# 		"icon" => "fa-user", "title" => "用户信息", 
	# 		"status" => current_user.name.blank?, 
	# 		"url" => kobe_user_path(current_user),
	# 		"opt" => btn_group(Suggestion.find(1).cando_list)
	# 	}
	# }
	# 左侧菜单 
	def left_bar(ha,act)
		str = %Q{
		<div class="col-md-3 md-margin-bottom-40">
			<ul class="list-group sidebar-nav-v1 margin-bottom-40">
		}
		ha.each do |key,value|
			str << left_bar_li(key,value,act)
		end
		str << %Q{
			</ul>   
		</div>
		}
		return raw str.html_safe
	end

	def left_bar_li(key,ha,act)
		click = ha["url"].blank? ? "javascript:void(0)" : "show_content('#{ha["url"]}','#{key} .show_content')"
		str = %Q{
			<li class="list-group-item#{act == key ? ' active' : ''}">
			#{ha["status"] ? '<span class="label label-yellow badge">未完成</span>' : ''}
				<a href="##{key}" data-toggle="tab" onClick="#{click}">
					<i class="fa #{ha["icon"]}"></i> #{ha["title"]}
				</a>
			</li>
		}
		return raw str.html_safe
	end

	# 右侧展示
	def show_content(ha,act)
		str = %Q{
		<div class="profile col-md-9">
			<div class="profile-body">
				<div class="tab-content">
		}
		ha.each do |key,value|
			str << show_tab(key,value,act)
		end
		str << %Q{
				</div>
			</div>
		</div>
		}
		return raw str.html_safe
	end

	def show_tab(key,ha,act)
		str = %Q{	
			<div class="profile-edit tab-pane fade#{act == key ? ' active in' : ''}" id="#{key}">
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

	def user_profile(ha,act)
		str = left_bar(ha,act)
		str << show_content(ha,act)
		return raw str.html_safe
	end


end