# -*- encoding : utf-8 -*-
module AboutStatus
	# 状态汉化
	def status_to_cn(status=self.status)
		arr = Dictionary.status[self.class.to_s.tableize]
    str = arr.nil? ? "未知" : arr.find{|n|n[1] == status}[0]
	end
	# 状态标签
	def status_to_badge(status=self.status)
		color = Dictionary.status_color[status % 6]
		"<span class='label rounded-2x label-#{color}'>#{self.status_to_cn(status)}</span>".html_safe
	end

end