# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  def sign_in
    @user = User.find_by(id:params[:format]) unless params[:format].blank?
    @user ||= User.new
  end

  def sign_up
  end

  def forgot_password
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
    redirect_to sign_in_users_path
  end

  def login
    user = User.find_by(email:params[:user][:email].downcase)
    if user && user.authenticate(params[:user][:password])
      sign_in_user(user, params[:user][:remember_me] == '1')
      if user.name.blank?
        flash_get('抱歉，您的资料还未填写，请先维护您的个人信息。',"info")
        redirect_to profile_kobe_users_path(user)
      else
        redirect_back_or kobe_index_path
      end
    else
      flash_get '用户名或者密码错误!'
      redirect_to sign_in_users_path
    end
    # unless user_params.blank?
    #   user = User.find_by "email = ?", user_params[:email]
    #   if user && user.decode_password == user_params[:password]
    #     session[:user_id] = user.id
    #     if user.name.blank?
    #       flash_get["请先完善您的个人信息。","warning"]
    #       redirect_to profile_kobe_users_path(user)
    #     else
    #       redirect_to kobe_index_path(user)
    #     end
    #   else
    #     flash_get("账号或者密码不正确，请重新输入。")
    #     redirect_to sign_in_users_path(@user)
    #   end
    # end 
  end

  def create
    # params.permit!
  	user = User.new(user_params)
    if user.save
      flash_get('抱歉，您的资料还未填写，请先维护您的个人信息。',"info")
      sign_in_user user
      # write_logs(user,'注册',remark='账号创建成功',user)
      # send_email(user.email,"#{Dictionary.web_site_name}激活邮件",'恭喜您注册成，请点击下列链接激活账号。XXXXXXXXXXX')
      redirect_to profile_kobe_users_path(user)
    else
      flash_get(user.errors.full_messages)
      render 'sign_up'
    end
  end

  def destroy
  end

  def update
  end

  def edit
  end


  private  

  # 注册时只允许传递过来的参数
  def user_params  
    params.require(:user).permit(:email, :password, :password_confirmation)  
  end

  def current_user=(user)
    @current_user = user
  end

  def sign_in_user(user,remember_me = false)
    remember_token = User.new_remember_token
    if remember_me
      cookies.permanent[:remember_token] = remember_token # 20年有效期
    else
      cookies[:remember_token] = remember_token # 30min 或关闭浏览器消失
    end
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user= user
  end

end
