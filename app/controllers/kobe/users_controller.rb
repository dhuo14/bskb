# -*- encoding : utf-8 -*-
class Kobe::UsersController < KobeController

  before_action :get_user, :only => [:edit, :show, :update, :profile]
  layout :false, :only => [ :show, :edit ]


  def edit
  end

  def show
  end

  def profile
    @arr = [
      { 
        "icon" => "fa-group", "title" => "单位信息", 
        "status" => @user.department.org_code.blank?,
        "url" => show_dep_kobe_department_path(@user.department),
        "opt" => @user.department.cando_list
      },
      { "icon" => "fa-list", "title" => "证件扫描件" },
      { "icon" => "fa-cubes", "title" => "资质证书" },
      { 
        "icon" => "fa-user", "title" => "用户信息", 
        "status" => @user.name.blank?, 
        "url" => kobe_user_path(@user),
        "opt" => @user.cando_list
      },
      { "icon" => "fa-bar-chart-o", "title" => "Overall" }
    ]
    @act = params[:format].blank? ? 0 : params[:format]
  end

  
  def impower
  end

  def change_password
  end

  def update()
    if update_and_write_logs(@user)
      tips_get("更新用户信息成功。")
      redirect_to profile_kobe_users_path(params[:tab_id])
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
    params[:id] ||= current_user.id
    @user = User.find(params[:id])
  end
end
