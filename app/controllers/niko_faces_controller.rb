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

class Date
  def self.days(start, count)
    days_array = Array.new
    date = start
    count.times do
      days_array << date
      date = date + 1
    end
    return days_array
  end
end

class NikoFacesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project, :authorize 
  before_filter :find_niko_face, :except => [:index, :new, :create, :preview, :backnumber]

  DISP_WEEK_NUM = 2
  DAY_OF_WEEK = 7

  def backnumber
    # 表示開始日を計算する
    set_printing_dates(params[:id].to_i)

    # カレンダーを構築する
    set_member_feelings
    set_team_feelings
  end

  def index
    # 表示開始日を計算する
    set_printing_dates(0)

    # カレンダーを構築する
    set_member_feelings
    set_team_feelings
  end

  def new
    niko_faces = NikoFace.where(:author_id => User.current.id).where(:date => Date.today);

    if niko_faces[0] == nil
      @niko_face = NikoFace.new
    else
      @niko_face = niko_faces[0]
      redirect_to edit_project_niko_face_path(@project, @niko_face.id)
    end
  end

  def create
    @niko_face = NikoFace.new(params[:niko_face])
    @niko_face.date = Date.today
    @niko_face.author = User.current

    if @niko_face.valid?
      if @niko_face.save    
        flash[:notice] = l(:notice_successful_create)
        redirect_to project_niko_faces_path(@project)
      end
    else
      render :action => 'new'
    end
  end

  def show
    # レスをすべて既読とする
    @niko_face.read_responses(User.current)

    # レス投稿用オブジェクト
    @niko_response = NikoResponse.new
  end

  def edit
  end

  def destroy
    @niko_face.destroy
    redirect_to project_niko_faces_path(@project)
  end

  def update 
    @niko_face.attributes = params[:niko_face]
    if @niko_face.valid?
      if @niko_face.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to project_niko_faces_path(@project)
      end
    else
      render :action => 'edit'
    end
    rescue ActiveRecord::StaleObjectError
      flash.now[:error] = l(:notice_locking_conflict)
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_niko_face
    @niko_face = NikoFace.find_by_id(params[:id])
    render_404    unless @niko_face
  end

  def set_printing_dates(backnumber)
    @backnumber = backnumber
    date = Date.today - ((DAY_OF_WEEK * DISP_WEEK_NUM) * (@backnumber + 1) ) + 1

    # 表示する期間の日付を@datesへ格納
    @dates = Date.days(date, DISP_WEEK_NUM * DAY_OF_WEEK)
  end

  def set_team_feelings
    @team_feelings = Hash.new

    # チームの気分を判定する
    @dates.each do |date|
      feelings = Array.new
      @users.each do|user|
        if @niko_faces[user.name][date.day] 
          feelings << @niko_faces[user.name][date.day].feeling
        end
      end
      @team_feelings[date.day] = feelings.numeric_average
    end
  end

  def set_member_feelings
    @niko_faces = Hash.new
    @users = Array.new

    # プロジェクトメンバーごとに気分を取得・格納
    @project.members.each do |member|
      # メンバーの気分を格納
      @niko_faces[member.user.name] = NikoFace.member_faces(member.user, @dates)
      @users << member.user
    end
  end
end

