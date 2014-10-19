class NikoResponse < ActiveRecord::Base
  unloadable

  validates_length_of :comment, :maximum => 128

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :response_to, :class_name => 'NikoFace', :foreign_key => 'niko_face_id'
end
