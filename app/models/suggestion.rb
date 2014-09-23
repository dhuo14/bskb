# -*- encoding : utf-8 -*-
class Suggestion < ActiveRecord::Base

	include AboutStatus

	def self.status_array
		[
	    ["未读",0,"orange",10,[1,4,101],[1,0]],
	    ["已读",1,"blue",50,[0,4],[3,4]],
	    ["已处理",3,"u",100,[1,4],[3,4]],
	    ["不需处理",4,"purple",100,[0,1,101],[3,4]],
	    ["已删除",101,"red",100,[0,1,3,4],nil]
    ]
  end

  def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	      <node name='邮箱地址' column='email' rules='{email:true}' placeholder='建议留下常用的邮箱，便于我们及时回复您'/>
	      <node name='QQ号码' column='QQ' rules='{digits:true}' messages='请输入正确的QQ号码' placeholder='建议留下常用的QQ号码，便于我们及时回复您'/>
	      <node name='手机号码' column='mobile' rules='{digits:true}' messages='请输入正确的手机号码' placeholder='建议留下常用的手机号码，便于我们及时回复您'/>
	      <node name='意见反馈' column='content' data_type='textarea' placeholder='请直接填写您遇到的问题或意见建议，您的意见对是我们前进的动力（800字以内）。' rules='{required:true, maxlength:800}' messages='800字以内'/>
	    </root>
	  }
	end

end
