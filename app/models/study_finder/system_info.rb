class StudyFinder::SystemInfo < ActiveRecord::Base
  self.table_name = 'study_finder_system_infos'

  validates_presence_of :secret_key, :default_email, :initials, :school_name
  # validates_format_of :secret_key, with: /[^0-9a-z]/i

  def self.current
    self.first
  end
end