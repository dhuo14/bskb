# -*- encoding : utf-8 -*-
class SharedController < JamesController
  # 下拉框选择时查询行业分类
  def department
    ztree_json(Department)
  end

  # 下拉框选择时查询地区
  def area
    ztree_json(Area)
  end

  private

end
