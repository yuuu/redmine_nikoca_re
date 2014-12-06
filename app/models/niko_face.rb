class Array
  def numeric_average
    average = nil
    if !empty?
      average = 0.0
      self.each do |value|
        average += value
      end
      average /= self.size
      average.truncate
    end
  end
end

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

  def self.project_member_faces(project, dates)
    project_member_faces = Hash.new
    project.members.each do |member|
      project_member_faces[member.user.name] = NikoFace.member_faces(member.user, dates)
    end
    return project_member_faces
  end

  def self.member_faces(user, dates)
    member_faces = Hash.new(dates.size)
    dates.each do |date|
      member_faces[date.day] = NikoFace.where(:author_id => user.id).where(:date => date)[0]
    end
    return member_faces
  end

  def self.team_feelings(project, dates)
    team_feelings = Hash.new(dates.size)
    dates.each do |date|
      team_feelings[date.day] = NikoFace.team_feeling(project, date)
    end
    return team_feelings
  end

  def self.team_feeling(project, date)
    feelings = Array.new
    project.members.each do|member|
      face = NikoFace.where(:author_id => member.user_id).where(:date => date)[0]
      feelings << face.feeling if face
    end
    return feelings.numeric_average
  end
end
