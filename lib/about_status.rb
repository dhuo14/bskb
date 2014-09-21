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
	def status_array(status=self.status)
		arr = Dictionary.status[self.class.to_s.tableize]
		return [] if status == 404 || arr.nil?
    return arr.find{|n|n[1] == status}
	end
	# 状态标签
	def status_badge(status=self.status)
		arr = self.status_array(status)
		if arr.blank?
			str = "<span class='label rounded-2x label-dark'>未知</span>"
		else
		 str = "<span class='label rounded-2x label-#{arr[2]}'>#{arr[0]}</span>"
		end
		return str.html_safe
	end

	# 状态进度条
	def status_progress_bar(status=self.status)
		arr = self.status_array(status)
		return "" if arr.blank?
		return %Q|
		<span class='heading-xs'>#{arr[0]} <span class='pull-right'>#{arr[3]}%</span></span>
		<div class='progress progress-u progress-xs'>
		<div style='width: #{arr[3]}%' aria-valuemax='100' aria-valuemin='0' aria-valuenow='#{arr[3]}' role='progressbar' class='progress-bar progress-bar-#{arr[2]}'></div>
		</div>|.html_safe
	end
end