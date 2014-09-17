# -*- encoding : utf-8 -*-
class Suggestion < ActiveRecord::Base

	include AboutStatus

  def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node name='意见反馈' column='content' data_type='textarea' placeholder='亲爱的中储粮服务网用户:请在这里直接填写您遇到的问题或意见建议，您的意见对中储粮服务网非常重要，是中储粮服务网前进的动力（500字以内）。' rules='{required:true, maxlength:500}' messages='500字以内'/>
	      <node name='邮箱地址' column='email' rules='{email:true}' placeholder='建议留下常用的邮箱，便于我们及时回复您'/>
	      <node name='QQ号码' column='QQ' rules='{digits:true}' messages='请输入正确的QQ号码' placeholder='建议留下常用的QQ号码，便于我们及时回复您'/>
	      <node name='手机号码' column='mobile' rules='{digits:true}' messages='请输入正确的手机号码' placeholder='建议留下常用的手机号码，便于我们及时回复您'/>
	    </root>
	  }
	end

end
