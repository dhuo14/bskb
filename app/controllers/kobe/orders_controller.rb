# -*- encoding : utf-8 -*-
class Kobe::OrdersController < KobeController

  def index
  end

  def new
  	obj = Order.new
  	obj.buyer = obj.payer = current_user.department.name
    @single_form = SingleForm.new(Order.xml,obj,{form_id: 'single_form', upload_files: true, title: '<i class="fa fa-question-circle"></i> 录入采购项目',action: kobe_orders_path, grid: 2})

    if obj.products.blank? 
      slave_objs = [OrdersProduct.new(order_id: obj.id),OrdersProduct.new(order_id: obj.id)]
    else
      slave_objs = obj.products
    end

    @ms_form = MasterSlaveForm.new(Order.xml,OrdersProduct.xml,obj,slave_objs,{form_id: 'ms_form', upload_files: true, title: '<i class="fa fa-question-circle"></i> 录入采购项目',action: kobe_orders_path, grid: 2},{title: '<i class="fa fa-angle-double-down"></i> 产品明细', grid: 4})
  
  # render :layout => false

  end

  def show
  end

  def edit
  end
end
