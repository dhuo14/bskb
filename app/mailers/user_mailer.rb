# -*- encoding : utf-8 -*-
class UserMailer < ActionMailer::Base
  default from: "zcladmin@163.com"
  # self.async = true

  def registration_confirmation(user)
  	@user = user
  	# email_with_name = "#{@user.name} <#{@user.email}>"
		mail(to: @user.email, subject: "激活邮件")
  end

end
