# -*- encoding : utf-8 -*-
class Order < ActiveRecord::Base
	has_many :products, class_name: :OrdersProduct
	has_many :uploads, class_name: :OrdersUpload, foreign_key: :master_id

	  # 附件的类
  def self.upload_model
    OrdersUpload
  end

	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node name='项目名称' column='name' hint='项目名称应该包含主要产品信息，例如：XXX直属库输送机采购项目' rules='{required:true, maxlength:80, minlength:6}'/>
	      <node name='采购单位' column='buyer' hint='一般是使用单位。' display='disabled' rules='{required:true}'/>
	      <node name='发票抬头' column='payer' hint='付款单位，默认与采购单位相同。' rules='{required:true}'/>
	      <node name='供应商名称' column='seller' rules='{required:true}'/>
	      <node name='交付日期' column='deliver_at' class='date_select' rules='{required:true, dateISO:true}'/>
	      <node name='预算金额（元）' column='bugget' rules='{required:true, number:true}'/>
	      <node name='发票编号' column='invoice_number'/>
	      <node name='备注' column='summary' data_type='textarea' placeholder='不超过800字'/>
	    </root>
	  }
	end
end
