$(document).ready(function() {
	var sign_in_rules = {
		"user[login]": { required: true, maxlength: 20, minlength: 6 },
		"user[password]": { required: true, maxlength: 20, minlength: 6 }
	};
	validate_form_rules('#sign_in_form',sign_in_rules);

	var sign_up_rules = {
		"user[dep]": { required: true, maxlength: 30, minlength: 6, remote: { url: '/users/valid_dep_name', type: "post" } },
		"user[login]": { required: true, maxlength: 20, minlength: 6, remote: { url: '/users/valid_user_login', type: "post" } },
		"user[email]": { required: true, email: true },
		"user[password]": { required: true, maxlength: 20, minlength: 6 },
		"user[password_confirmation]": { required: true, maxlength: 20, minlength: 6, equalTo: '#user_password' },
		"user[agree]": { required: true }
	}
	validate_form_rules('#sign_up_form',sign_up_rules);

	// 注册 点击用户注册条款的我同意 勾选checkbox
	$("#user_agreements #agree_btn").on("click", function(){
		$("#user_agree").attr("checked",true);
	});
	
});