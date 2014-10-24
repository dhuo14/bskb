# -*- encoding : utf-8 -*-
class Kobe::OrdersController < KobeController
  def index
  end

  def new
  	@master = Order.new
  	@master_xml = Order.xml
  	@slave_xml = OrdersProduct.xml
  	@master.buyer = @master.payer = current_user.department.name
  end

  def show
  end

  def edit
  end
end
