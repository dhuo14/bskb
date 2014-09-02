# -*- encoding : utf-8 -*-
module AboutStatus
	# 状态汉化
	def status_to_cn
		arr = Dictionary.status[self.class.to_s.tableize]
    str = arr.nil? ? "未知" : arr.find{|n|n[1] == self.status}[0]
	end
	# 状态标签
	def status_to_badge
		color = Dictionary.status_color[self.status % 6]
		"<span class='label label-#{color}'>#{self.status_to_cn}</span>".html_safe
	end

end