//= require application
//= require form
//= require plugins/jquery.ztree.all-3.5

// 登录sign_in_form验证
var Validation_sign_in_form = function () {
	return {       
		initValidation: function () {
			$('#sign_in_form').validate({                   
				rules:
				{
					"user[login]": { required: true, maxlength: 20, minlength: 6 },
					"user[password]": { required: true, maxlength: 20, minlength: 6 }
				},
				messages:
				{
					// "user[login]": "请输入登录名" ,
					// "user[password]": "请输入密码" 
				},                  
				errorPlacement: function(error, element)
				{
					error.insertAfter(element.parent());
				}
			});
		}
	};
}();

// 注册sign_up_form验证
var Validation_sign_up_form = function () {
	return {       
		initValidation: function () {
			$('#sign_up_form').validate({                   
				rules:
				{
					"user[dep]": { required: true, maxlength: 30, minlength: 6, remote: { url: '/users/valid_dep_name', type: "post" } },
					"user[login]": { required: true, maxlength: 20, minlength: 6, remote: { url: '/users/valid_user_login', type: "post" } },
					"user[email]": { required: true, email: true },
					"user[password]": { required: true, maxlength: 20, minlength: 6 },
					"user[password_confirmation]": { required: true, maxlength: 20, minlength: 6, equalTo: '#user_password' },
					"user[agree]": { required: true }
				},
				messages:
				{
					// "user[dep]": "您填写的公司名称格式有误,请输入6-30位公司名称",
					// "user[login]": "您填写的登录名格式有误,请输入6-20位登录名",
					// "user[email]": "您填写的Email格式有误,请重新输入",
					// "user[password]": "您填写的密码格式有误,请输入6-20位密码",
					// "user[password_confirmation]": "您填写密码不一致，请重新输入",
					// "user[agree]": "请阅读用户注册条款"
				},                  
				errorPlacement: function(error, element)
				{
					error.insertAfter(element.parent());
				}
			});
		}
	};
}();

jQuery(document).ready(function() {
	Validation_sign_in_form.initValidation();
	Validation_sign_up_form.initValidation();

	// 注册 点击用户注册条款的我同意 勾选checkbox
	$("#user_agreements #agree_btn").on("click", function(){
		$("#user_agree").attr("checked",true);
	});

	
});