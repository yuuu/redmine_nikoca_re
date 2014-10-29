class NikoFacesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project, :authorize
  before_filter :find_niko_face, :except => [:index, :new, :create, :preview]

  DISP_WEEK_NUM = 2
  DAY_OF_WEEK = 7

  def index
    @users = Array.new
    @days = Array.new
    @niko_faces = Hash.new

    # 表示する期間の日付を@daysへ格納
    date = Date.today - (DAY_OF_WEEK * DISP_WEEK_NUM) + 1
    (DISP_WEEK_NUM * DAY_OF_WEEK).times do
      @days << date
      date = date + 1
    end

    # プロジェクトメンバーごとに気分を取得・格納
    Member.where(project_id: @project.id).each do |member|
      faces = Hash.new

      # ユーザ情報を取得
      user = User.find(member.user_id)
      @users << user

      # 各日数分気分を取得
      @days.each do |day|
        faces[day.day] = NikoFace.where(:author_id => member.user_id).where(:date => day)[0];
      end

      # メンバーの気分を格納
      @niko_faces[user.name] = faces
    end
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
    # レス投稿用オブジェクト
    @niko_response = NikoResponse.new
  end

  def edit
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
end

