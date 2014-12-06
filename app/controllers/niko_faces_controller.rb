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

  DAY_OF_WEEK = 7
  DISP_WEEK_NUM = 2
  DISP_DAY_NUM = DISP_WEEK_NUM * DAY_OF_WEEK

  def backnumber
    # 表示開始日を計算する
    @backnumber = params[:id].to_i
    @dates = get_dates(@backnumber)

    # カレンダーを構築する
    @niko_faces = NikoFace.project_member_faces(@project, @dates)
    @users = get_users(@project)
    @team_feelings = NikoFace.team_feelings(@project, @dates)
  end

  def index
    # 表示開始日を計算する
    @backnumber = 0
    @dates = get_dates(@backnumber)

    # カレンダーを構築する
    @niko_faces = NikoFace.project_member_faces(@project, @dates)
    @users = get_users(@project)
    @team_feelings = NikoFace.team_feelings(@project, @dates)
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

  def get_dates(backnumber)
    date = Date.today - (DISP_DAY_NUM * (backnumber + 1)) + 1
    dates = Date.days(date, DISP_DAY_NUM)
    return dates
  end

  def get_users(project)
    users = Array.new
    project.members.each do |member|
      users << member.user
    end
    return users
  end
end

