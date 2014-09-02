# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
	# 树形结构
  has_ancestry :cache_depth => true
  default_scope -> {order(:ancestry, :sort, :id)}
  
  include AboutAncestry

end
