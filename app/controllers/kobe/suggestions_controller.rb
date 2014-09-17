# -*- encoding : utf-8 -*-
class Kobe::SuggestionsController < KobeController

  skip_before_action :verify_authenticity_token, :only => [ :destroy, :mark_as_read, :mark_as_unread ]
  before_action :get_suggestion, :only => [ :show, :destroy, :mark_as_read, :mark_as_unread ]

  def show

  end

  def create
    if create_and_write_logs(Suggestion)
      tips_get("创建成功。")
    else
      flash_get(suggestion.errors.full_messages)
    end
    redirect_back_or
  end

  def list
    @suggestions = Suggestion.all
  end

  def destroy
    change_status_and_write_logs(@suggestion,98,'删除')
    redirect_to list_kobe_suggestions_path
  end

  # 标记为已读
  def mark_as_read
    change_status_and_write_logs(@suggestion,3,'标记为已读')
    redirect_to list_kobe_suggestions_path
  end

  # 标记为未读
  def mark_as_unread
    change_status_and_write_logs(@suggestion,0,'标记为未读')
    redirect_to list_kobe_suggestions_path
  end

  # 批量处理(删除、标记为已读、标记为未读)
  def batch_opt
    unless params[:check].blank?
      case params[:batch_opt]
      when "delete"
        batch_change_status_and_write_logs(Suggestion, params[:check].to_a,98,'删除')
      when "read"
        batch_change_status_and_write_logs(Suggestion, params[:check].to_a, 3, '标记为已读')
      when "unread"
        batch_change_status_and_write_logs(Suggestion, params[:check].to_a, 0, '标记为未读')
      when "clean"
        Suggestion.destroy_all(id: params[:check].to_a)
      end
    end 
    redirect_to list_kobe_suggestions_path
  end


  private  

    def get_suggestion
      @suggestion = Suggestion.find(params[:id]) unless params[:id].blank? 
    end
end
