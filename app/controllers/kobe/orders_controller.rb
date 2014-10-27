# -*- encoding : utf-8 -*-
class Kobe::OrdersController < KobeController

  def index
  end

  def new
  	@master = Order.new
  	@master_xml = Order.xml
  	@slave_xml = OrdersProduct.xml
  	@master.buyer = @master.payer = current_user.department.name
    @myform = SingleForm.new(Order.xml,Order.new,{upload_files: true, title: '<i class="fa fa-question-circle"></i> 录入采购项目',action: kobe_orders_path, grid: 2})
  
  # render :layout => false

  end

  def show
  end

  def edit
  end
end
