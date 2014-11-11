# -*- encoding : utf-8 -*-
class Kobe::OrdersController < KobeController

  before_action :get_obj, :only => [:show, :edit, :update, :destroy]
  def index
  end

  def new
  	obj = Order.new
  	obj.buyer = obj.payer = current_user.department.name
    @single_form = SingleForm.new(Order.xml,obj,{form_id: 'single_form', upload_files: false, title: '<i class="fa fa-question-circle"></i> 录入采购项目',action: kobe_orders_path, grid: 2})

    if obj.products.blank? 
      slave_objs = [OrdersProduct.new(order_id: obj.id),OrdersProduct.new(order_id: obj.id)]
    else
      slave_objs = obj.orders_products
    end

    @ms_form = MasterSlaveForm.new(Order.xml,OrdersProduct.xml,obj,slave_objs,{form_id: 'ms_form', upload_files: true, title: '<i class="fa fa-pencil-square-o"></i> 下单',action: kobe_orders_path, grid: 2},{title: '产品明细', grid: 4})
  
  # render :layout => false

  end

  def show
  end

  def create
    create_msform_and_write_logs(Order,OrdersProduct,{:action => "下单", :master_title => "基本信息",:slave_title => "产品信息"})
    render :text => params
  end

  def update
    update_msform_and_write_logs(@obj,OrdersProduct,{:action => "修改订单", :master_title => "基本信息",:slave_title => "产品信息"})
    render :text => params
  end

  def edit
    slave_objs = @obj.products
    @ms_form = MasterSlaveForm.new(Order.xml,OrdersProduct.xml,@obj,slave_objs,{upload_files: true, title: '<i class="fa fa-pencil-square-o"></i> 修改订单',action: kobe_order_path(@obj), method: "patch", grid: 2},{title: '产品明细', grid: 4})
  end

  private

    def get_obj
      @obj = Order.find(params[:id]) unless params[:id].blank? 
    end

end
