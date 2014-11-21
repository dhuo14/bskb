class CategoriesParam < ActiveRecord::Base
	belongs_to :category

	def self.xml(who='',options={})
	  %Q{
	    <?xml version='1.0' encoding='UTF-8'?>
	    <root>
	    	<node column='id' data_type='hidden'/>
	    	<node name='参数名称' column='name' class='required'/>
	    	<node name='字段名称' column='column' hint='数据库里的字段名称'/>
	    	<node name='参数类型' column='data_type' data_type='select' class='required' data='[["text","字符类型"],["email","电子邮件类型"],["url","网址类型"],["date","日期类型"],["dateISO","日期类型(YYYY-MM-DD)"],["number","数字类型"],["digits","整数类型"],["radio","单选"],["checkbox","多选"],["select","下拉单选"],["multiple_select","下拉多选"],["textarea","大文本类型"],["richtext","富文本类型"],["hidden","隐藏类型"]]'/>
	    	<node name='选择项' hint='单选、多选、下拉单选、下拉多选必须填写选择项，以"|"分割'/>
	    	<node name='是否必填' column='is_required' class='required' data_type='radio' data='[[1,"是"],[0,"否"]]'/>
	      <node name='提示' column='hint'/>
	      <node name='占位符' column='placeholder'/>
	    </root>
	  }
	end
end
