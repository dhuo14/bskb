# -*- encoding : utf-8 -*-
class Kobe::UsersController < KobeController
  before_action :get_user, :only => [:profile, :rest_account, :update]

  def edit
  end

  def profile
  end

  
  def impower
  end

  def change_password
  end

  def update()
  	if @user.update(update_params)
	    tips_get("保存成功") 
	    redirect_to profile_kobe_users_path(@user)
  	else
      flash_get(@user.errors.full_messages)
  		render 'profile'
  	end
  end

  private  

  # 修改用户时只允许传递过来的参数
  def update_params(act='profile')  
    ha={
      "profile" => %w(name gender birthday identity_num email mobile is_visible tel fax duty professional_title bio),
      "impower" => %w(is_admin status),
      "change_password" => %w(password password_confirmation)
    }
    params.require(:user).permit(ha[act]) 
  end

  def get_user
  	# @user = User.find(params[:format])
    @user = current_user
  end
  
end
