class NikoFace < ActiveRecord::Base
  unloadable

  validates_presence_of :feeling
  validates_length_of :comment, :maximum => 128

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :responses, :class_name => 'NikoResponse', :dependent => :destroy 
end
