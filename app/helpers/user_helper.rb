# -*- encoding : utf-8 -*-
module UserHelper

	# render partial的Helper方法 
	def render_html(partial_path, locals = {})
	  raw render(partial: partial_path, locals: locals).html_safe
	end

	# 页面提示信息(不是弹框) 
	def show_tips(type,title='',msg='')
		if msg.is_a?(Array)
			msg = msg.map{|m|content_tag(:p,m)}.join
		else
			msg = content_tag(:p,msg)
		end
		return raw %Q|
			<div class="alert #{get_alert_style(type)} fade in">
				<button class="close" aria-hidden="true" data-dismiss="alert" type="button">×</button>
				<h4>#{title}</h4>
				#{msg}
			</div>|.html_safe
	end

	# modal弹框 
	# 按钮要有href="#div_id" data-toggle="modal"
	# 例如<a class="btn btn-sm btn-default" href="#div_id" data-toggle="modal">
	def modal_dialog(div_id='modal_dialog',content='',title='提示')
		raw render_html('/shared/dialog/modal_dialog', div_id: div_id, content: content, title: title).html_safe
	end

	# 提示信息的样式
	def get_alert_style(type)
		case type
		when "error"
			return 'alert-danger'
		when "tips"
			return 'alert-success'
		when "warning"
			return 'alert-warning'
		else # "info"
			return 'alert-info'
		end
	end
end