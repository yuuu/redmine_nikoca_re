class NikoFace < ActiveRecord::Base
  unloadable

  validates_presence_of :feeling
  validates_length_of :comment, :maximum => 128

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :responses, :class_name => 'NikoResponse', :dependent => :destroy 

  def read_responses(user)
    if user.id == self.author.id
      self.responses.each do |response|
        response.read
      end
    end
  end

  def has_unread_resnponses?(user)
    unread = false
    if user.id == self.author.id
      self.responses.each do |response|
        unread |= response.is_unread?
      end
    end
    unread
  end

  def self.member_faces(user, dates)
    faces = Hash.new(dates.size)
    dates.each do |date|
      faces[date.day] = NikoFace.where(:author_id => user.id).where(:date => date)[0]
    end
    return faces
  end
end
