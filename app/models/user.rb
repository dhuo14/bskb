# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  before_save {self.email = email.downcase}
  before_create :create_remember_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with:VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, :on => :create

  belongs_to :department
  has_and_belongs_to_many :menus
  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles
  # 收到的消息
  has_many :unread_notifications, -> { where "status=0" }, class_name: "Notification", foreign_key: "receiver_id"  

  include AboutStatus

  # 是否超级管理员,超级管理员不留操作痕迹
  def admin?
    self.roles.map(&:name).include?("系统管理员")
  end



  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end


  # 获取当前人的菜单
  def show_menus
    return menus_ul(Menu.to_depth(0))
  end

  private

  def create_remember_token
    self.remember_token=User.encrypt(User.new_remember_token)
  end

  # 在layout中展开菜单menu
  def menus_ul(mymenus = [])
    str = "<ul class='nav nav-stacked'>"
    mymenus.each{|m| str << menus_li(m) }
    str << "</ul>"
    return str
  end

  def menus_li(menu)
    if menu.icon.blank?
      case menu.depth
      when 0
        menu.icon = "icon-caret-right"  
      when 1
        menu.icon = "icon-chevron-right"
      else
        menu.icon = "icon-angle-right"
      end
    end
    unless menu.has_children?
      str = "<li><a href='#{menu.route_path}'><i class='#{menu.icon}'></i><span>#{menu.name}</span></a></li>"
    else
      str = "<li><a class='dropdown-collapse' href='#{menu.route_path}'><i class='#{menu.icon}'></i><span>#{menu.name}</span><i class='icon-angle-down angle-down'></i></a>"
      str << menus_ul(menu.children)
      str << "</li>"
    end
    return str
  end

end
