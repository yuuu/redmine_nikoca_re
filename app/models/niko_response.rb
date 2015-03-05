# Redmine_Nikoca_Re プラグイン NikoResponse
# @author yuuu(Yuhei Okazaki)
class NikoResponse < ActiveRecord::Base
  unloadable

  attr_accessible :comment

  validates_presence_of :comment
  validates_length_of :comment, :maximum => 128

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :response_to, :class_name => 'NikoFace', :foreign_key => 'niko_face_id'

  # 既読とする
  def read
    unread = self.unread
    self.unread = false

    if unread
      begin
        save
      rescue ActiveRecord::StaleObjectError
        reload
        reschedule_on(date)
        save
      end
    end
  end

  # 未読か？
  # @return 未読であればtrue
  def is_unread?
    self.unread
  end
end
