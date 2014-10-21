# -*- encoding : utf-8 -*-
module ValidForm

	def valid_unique_dep_name(name,id=0)
		return Department.where(["name = ? and id != ?", name, id]).blank? ? true : false
	end

	def valid_unique_user_login(login)
		return User.where(login: login).blank? ? true : false
	end
	
end