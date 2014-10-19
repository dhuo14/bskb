# -*- encoding : utf-8 -*-
class SuggestionsUpload < ActiveRecord::Base
  belongs_to :master, class_name: "Suggestion", foreign_key: "master_id"

  has_attached_file :upload, :styles => {:thumbnail => "45x45",:big =>"976x153#"}
  before_post_process :allow_only_images

  include Rails.application.routes.url_helpers
  include UploadFiles

end
