var Treepicker = function () {

    return {
        
        //Datepickers
        initTreepicker: function () {
	        // Regular Treepicker
	        $('.dialog_select').on("click",function(){
						var d = dialog({
							title: '消息',
							content: '风吹起的青色衣衫，夕阳里的温暖容颜，你比以前更加美丽，像盛开的花<br>——许巍《难忘的一天》',
							okValue: '确 定',
							ok: function () {
								var that = this;
								setTimeout(function () {
									that.title('提交中..');
								}, 2000);
								return false;
							},
							follow: this,
							cancelValue: '取消',
							cancel: function(){}
						});
						d.show();
	        })
        }
    };
}();