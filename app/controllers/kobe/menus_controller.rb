# -*- encoding : utf-8 -*-
class Kobe::MenusController < KobeController
  # load_and_authorize_resource
  
  skip_before_action :verify_authenticity_token, :only => [ :move,:destroy ]
  # protect_from_forgery :except => :index
  before_action :get_menu, :only => [ :edit, :update, :destroy ]
  before_action :get_icon, :only => [ :new, :index, :edit ]
  layout false, :only => [ :edit, :new ]

	def index
		@menu = Menu.new
	end

  def new
  	@menu = Menu.new
  end

  def edit

  end

  def create
    menu = Menu.new(menu_params)
    if menu.save
      tips_get("操作成功。")
      redirect_to kobe_menus_path
    else
      flash_get(menu.errors.full_messages)
      render 'index'
    end
  end

  def update
    if @menu.update(menu_params)
      tips_get("操作成功。")
      redirect_to kobe_menus_path
    else
      flash_get(@menu.errors.full_messages)
      render 'index'
    end
  end

  def destroy
    if @menu.destroy
      render :text => "删除成功！"
    else
      render :text => "操作失败！"
    end
  end

  def move
    ztree_move(Menu)
  end

  def ztree
    ztree_json(Menu)
  end

  private  

    # 只允许传递过来的参数
    def menu_params  
      params.require(:menu).permit(:name, :url, :icon, :sort, :status, :parent_id)  
    end

    def get_menu
      @menu = Menu.find(params[:id]) unless params[:id].blank?
    end

    def get_icon
      @icon = Icon.leaves.map(&:name)
    end

end
