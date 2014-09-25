# -*- encoding : utf-8 -*-
module KobeHelper

  # 日期筛选,用于list列表页面
  def date_filter(arr=[])
    if arr.blank?
      arr = [
        ["最近三个月","3m"],
        ["最近半年","6m"],
        ["最近一年","1y"],
        ["最近两年","2y"],
        ["最近三年","3y"],
        ["今年以内","ty"],
        ["全部时间","all"]
      ]
    end
    return head_filter("date_filter",arr)
  end

  # 状态筛选,用于list列表页面
  def status_filter(model,action='')
    arr = model.status_filter(action).push(["全部状态","all"])
    return head_filter("status_filter",arr)
  end
  
end