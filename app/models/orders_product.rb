# -*- encoding : utf-8 -*-
class OrdersProduct < ActiveRecord::Base
	belongs_to :order
	
	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node column='category_code' data_type='hidden'/>
	    	<node name='品目' class='tree_radio' json_url='/json/areas' partner='category_code' rules='{required:true}'/>
	    	<node name='品牌' column='brand' rules='{required:true}'/>
	    	<node name='型号' column='model' rules='{required:true}'/>
	    	<node name='版本号' column='version' hint='颜色、规格等有代表性的信息，可以不填。'/>
	      <node name='市场单价（元）' column='market_price' rules='{required:true, number:true}'/>
	      <node name='入围单价（元）' column='bid_price' rules='{required:true, number:true}'/>
	      <node name='成交单价（元）' column='price' rules='{required:true, number:true}'/>
	      <node name='数量' column='quantity' rules='{required:true, number:true}'/>
	      <node name='单位' class='required' column='unit'/>
	      <node name='小计（元）' column='total' rules='{required:true, number:true}'/>
	      <node name='备注' column='summary' data_type='textarea' placeholder='不超过800字'/>
	    </root>
	  }
	end
end
