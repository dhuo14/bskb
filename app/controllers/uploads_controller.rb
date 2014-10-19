# -*- encoding : utf-8 -*-
class UploadsController < KobeController
  skip_before_action :verify_authenticity_token, :only => :destroy
  layout false

  def index
    @uploads = get_model.where(["master_id = ?", params[:master_id]])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uploads.map{|upload| upload.to_jq_upload } }
    end
  end

  def create
    @upload = get_model.new(form_params)
    @upload.master_id = params[:master_id]
    respond_to do |format|
      if @upload.save
        format.html {
          render :json => [@upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@upload.to_jq_upload]}, status: :created, location: "/uploads" }
      else
        format.html { render action: "new" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @upload = get_model.find(params[:id])
    # 稍微加一个判断
    if verify_authority(@upload.master_id == params[:master_id].to_i)
      @upload.destroy 
    end
    respond_to do |format|
      format.html { redirect_to uploads_path }
      format.json { head :no_content }
    end
  end

  private

  # 从参数中获得附件的Model
  def get_model
    params[:upload_model].constantize
  end

  # 附件参数过滤
  def form_params
    params.require(:upload_file).permit!
  end
end
