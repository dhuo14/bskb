class CategoriesParam < ActiveRecord::Base
	belongs_to :category

	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node column='id' data_type='hidden'/>
	    	<node name='参数名称' column='name' class='required'/>
	    	<node name='参数类型' column='data_type' class='required'/>
	    	<node name='参数别名' column='column'/>
	    	<node name='是否必填' column='is_required' class='required' data_type='radio' data='[[1,"是"],[0,"否"]]'/>
	      <node name='提示' column='hint'/>
	      <node name='占位符' column='placeholder'/>
	    </root>
	  }
	end
end
