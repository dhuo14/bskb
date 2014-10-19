class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # 开发给view层用的方法
  helper_method :current_user, :signed_in?, :redirect_back_or, :cando_list, :get_node_value, :hash_to_string

  # cancan 权限校验
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to errors_path, :alert => exception.message
    # render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

  # 当前用户
  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    User.current ||= User.find_by(remember_token:remember_token) 
  end
 
  # 是否登录?
  def signed_in?
    !current_user.nil?
  end
  
  # 后退页面
  def redirect_back_or(default=root_path)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  protected

    # 生产ztree的json
    def ztree_json(obj_class)
      return render :json => obj_class.get_json(params[:name])
    end

    # 设置后退页面
    def store_location
      session[:return_to] = request.fullpath if request.get?
    end

    # 需要登录
    def request_signed_in!
      unless signed_in?
        flash_get '请先登录!'
        redirect_to sign_in_users_path
      end
    end

    # 验证身份
    def verify_authority(boolean)
      return current_user.admin? ? true : boolean
    end

    #着重提示，等用户手动关闭
    def flash_get(message,status="error")
      unless message.class == Array
        message = [message]
      end
      flash[status] = message
    end

    #普通提示，自动关闭
    def tips_get(message)
      flash[:tips] = message
    end

    # 发送邮件
    def send_email(email,title,content)
      # 这里是发送邮件的代码，暂缺
    end

    # 哈希转成syml格式的字符串，供JS调用
    def hash_to_string(ha)
      if ha.class == Hash
        arr = []
        ha.each do |key,value|
          arr << "#{key}:#{hash_to_string(value)}"
        end
        return "{#{arr.join(',')}}"
      elsif ha.class == String
        return "'#{ha}'"
      else
        return ha
      end
    end

    include SaveXmlForm
    include ValidForm

end
