# -*- encoding : utf-8 -*-
module AboutStatus
	def self.included(base)
    base.extend(StatusClassMethods)
  end

  # 拓展类方法
  module StatusClassMethods
	  def cn_to_status(cn)
			arr = Dictionary.status[self.to_s.tableize]
	    if arr.nil?
	    	return 404
	    else
	    	result = arr.find{|n|n[0] == cn}
	    	if result
	    		return result[1]
	    	else
	    		return 404
	    	end
	    end
	  end
	end

	# 状态汉化
	def status_to_cn(status=self.status)
		return "未知" if status == 404
		arr = Dictionary.status[self.class.to_s.tableize]
    if arr.nil?
    	return "未知" 
    else
    	result = arr.find{|n|n[1] == status}
    	if result
    		return result[0]
    	else
    		return "未知"
    	end
    end
	end
	# 状态标签
	def status_to_badge(status=self.status)
		color = Dictionary.status_color[status % 6]
		return "<span class='label rounded-2x label-#{color}'>#{self.status_to_cn(status)}</span>".html_safe
	end

end