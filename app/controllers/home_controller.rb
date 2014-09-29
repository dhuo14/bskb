# -*- encoding : utf-8 -*-
class HomeController < JamesController
  # layout "application" ,:only => :test

	def test
		# redirect_to profile_kobe_users_path(current_user)
		# Setting.audit_money = {"汽车采购" => 180000, "办公小额" => 3000}
        @tmp = "
        <p>读取字典数据（静态配置信息）：#{Dictionary.company_name}</p>
        <br/>
        <p>默认时间格式：#{Time.new.to_s(:db)}</p>"
        @city = Area.find(1)
	end

    def ajax_test
        render :text => "这是来自ajax的内容。"
    end

	def index
	end
	
    def testform
        @obj = Department.new
        @obj2 = Department.find(1)
        render :layout => "kobe"
    end

end
