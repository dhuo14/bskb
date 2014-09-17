# -*- encoding : utf-8 -*-
class KobeController < ApplicationController
  # before_action :request_signed_in!
  before_action :store_location, :init_themes

  def index
    @user = current_user
    UserMailer.registration_confirmation(@user).deliver
    render :text => "sdfsdfsdf"
  end

  def test
    Setting.audit_money = {"汽车采购" => 180000, "办公小额" => 3000}
    @tmp = "
    <p>读取字典数据（静态配置信息）：#{Dictionary.company_name}</p>
    <br/>
    <p>读取设置数据（动态配置信息）：#{Setting.audit_money["汽车采购"].to_s}</p>
    <br/>
    <p>默认时间格式：#{Time.new.to_s}</p>
    <br/>
    <p>中文时间格式：#{Time.new.to_s(:cn_time)}</p>"
    @city = Area.find(1)
  end

  # 类模型的json格式，tree_select使用
  def obj_class_json
    obj_class = params[:obj_class]
    if obj_class.blank?
      str = '[]'
    else
      begin
        str = obj_class.constantize.get_json(params[:name])
      rescue 
        str = '[]'
      end
    end
    return render :json => str
  end
  
  # 以下是公用方法
  protected

  # 树节点移动
  def ztree_move(obj_class)
    render :text => obj_class.ztree_move_node(params[:sourceId],params[:targetId],params[:moveType],params[:isCopy])
  end

  # 以下是私有方法
  private 
  
  # 准备主界面的素材 ---- #未读短信息
  def init_themes
    # @unread_notifications = current_user.unread_notifications
  end

  

end
