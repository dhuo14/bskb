# -*- encoding : utf-8 -*-
class DepartmentsUpload < ActiveRecord::Base
  belongs_to :master, class_name: "Department", foreign_key: "master_id"

  has_attached_file :upload, :styles => {:thumbnail => "45x45",:big =>"976x153#"}
  validates_attachment_content_type :upload, :content_type => /\Aimage\/.*\Z/
  before_post_process :allow_only_images

	include Rails.application.routes.url_helpers
  include UploadFiles

end