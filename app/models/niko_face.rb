# Redmine_Nikoca_Re プラグイン NikoFace
# @author yuuu(Yuhei Okazaki)

# @abstract Arrayクラスにnumeric_averageメソッドを拡張
class Array
  # 平均値を整数値で取得する
  # @return 配列値の平均値(整数)
  def numeric_average
    average = nil
    if !empty?
      average = 0.0
      self.each do |value|
        average += value
      end
      average /= self.size
      average.round
    end
  end
end

# ニコカレへ記入する気分を保持する
# 併せて、記入者、記入日、コメント、レスポンスの登録・操作も
# 定義する
# @abstract ニコカレへ記入する気分を保持する
class NikoFace < ActiveRecord::Base
  unloadable

  validates_presence_of :feeling
  validates_length_of :comment, :maximum => 128

  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  has_many :responses, :class_name => 'NikoResponse', :dependent => :destroy

  # レスポンスを既読とする
  # @params user [User] カレントユーザ
  def read_responses(user)
    if user.id == self.author.id
      self.responses.each do |response|
        response.read
      end
    end
  end

  # レスポンスは未読か？
  # @params user [User] カレントユーザ
  # @return 未読が存在すればtrue
  def has_unread_resnponses?(user)
    unread = false
    if user.id == self.author.id
      self.responses.each do |response|
        unread |= response.is_unread?
      end
    end
    unread
  end

  # プロジェクトメンバの気分を取得
  # @param project [Project] 取得対象となるプロジェクト
  # @param dates [Array] 取得対象となる日付リスト
  # @return [Hash] プロジェクトメンバの気分
  # project_member_faces[user.id][date.day]
  def self.project_member_faces(project, dates)
    project_member_faces = Hash.new
    project.members.each do |member|
      project_member_faces[member.user.name] = NikoFace.member_faces(member.user, dates)
    end
    return project_member_faces
  end

  # メンバの気分を取得
  # @param user [User] 取得対象となるユーザ
  # @param dates [Array] 取得対象となる日付リスト
  # @return [Hash] メンバの気分
  # member_faces[date.day]
  def self.member_faces(user, dates)
    member_faces = Hash.new(dates.size)
    dates.each do |date|
      member_faces[date.day] = NikoFace.where(:author_id => user.id).where(:date => date)[0]
    end
    return member_faces
  end

  # チームの気分リストを取得
  # @param project [Project] 取得対象となるプロジェクト
  # @param dates [Array] 取得対象となる日付リスト
  # @return [Hash] チームの気分リスト
  # team_feelings[date.day]
  def self.team_feelings(project, dates)
    team_feelings = Hash.new(dates.size)
    dates.each do |date|
      team_feelings[date.day] = NikoFace.team_feeling(project, date)
    end
    return team_feelings
  end

  # チームの気分を取得
  # @param project [Project] 取得対象となるプロジェクト
  # @param date [Date] 取得対象となる日付
  # @return [Integer] チームの気分
  def self.team_feeling(project, date)
    feelings = Array.new
    project.members.each do|member|
      face = NikoFace.where(:author_id => member.user_id).where(:date => date)[0]
      feelings << face.feeling if face
    end
    return feelings.numeric_average
  end
end
