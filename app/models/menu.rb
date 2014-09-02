# -*- encoding : utf-8 -*-
class Menu < ActiveRecord::Base
  has_and_belongs_to_many  :users
  # 树形结构
  has_ancestry :cache_depth => true
  default_scope -> {order(:ancestry, :sort, :id)}

	include AboutAncestry

  private

end
