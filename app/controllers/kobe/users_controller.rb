# -*- encoding : utf-8 -*-
class Kobe::UsersController < KobeController
  # before_action :get_user, :only => [:profile, :rest_account, :update]
  before_action :get_user, :only => [:edit, :show, :update]

  def edit
  end

  def show
  end

  def profile
  end

  
  def impower
  end

  def change_password
  end

  def update()
    if update_and_write_logs(@user)
      tips_get("更新用户信息成功。")
      redirect_to kobe_user_path(@user)
    else
      flash_get(@user.errors.full_messages)
      redirect_back_or
    end
  end

  private  

  # # 修改用户时只允许传递过来的参数
  # def update_params(act='profile')  
  #   ha={
  #     "profile" => %w(name gender birthday identity_num email mobile is_visible tel fax duty professional_title bio),
  #     "impower" => %w(is_admin status),
  #     "change_password" => %w(password password_confirmation)
  #   }
  #   params.require(:user).permit(ha[act]) 
  # end

  def get_user
    @user = User.find(params[:id]) unless params[:id].blank? 
  end
end
