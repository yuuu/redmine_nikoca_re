class NikoFacesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project, :authorize 
  before_filter :find_niko_face, :except => [:index, :new, :create, :preview, :backnumber]

  DISP_WEEK_NUM = 2
  DAY_OF_WEEK = 7

  def backnumber
    # 表示開始日を計算する
    @backnumber = params[:id].to_i
    date = Date.today - ((DAY_OF_WEEK * DISP_WEEK_NUM) * (@backnumber + 1) ) + 1

    # カレンダーを構築する
    create_calender(date)
  end

  def index
    # 表示開始日を計算する
    date = Date.today - (DAY_OF_WEEK * DISP_WEEK_NUM) + 1

    # カレンダーを構築する
    create_calender(date)
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

  def create_calender(start_date)
    @users = Array.new
    @days = Array.new
    @niko_faces = Hash.new
    @team_feelings = Hash.new

    # 表示する期間の日付を@daysへ格納
    (DISP_WEEK_NUM * DAY_OF_WEEK).times do
      @days << start_date
      @team_feelings[start_date.day] = 0.0
      start_date = start_date + 1
    end

    # プロジェクトメンバーごとに気分を取得・格納
    Member.where(project_id: @project.id).each do |member|
      faces = Hash.new

      # ユーザ情報を取得
      user = User.find(member.user_id)
      @users << user

      # 各日数分気分を取得
      user_faces = NikoFace.where(:author_id => user.id)
      @days.each do |day|
        faces[day.day] = user_faces.where(:date => day)[0];
      end

      # メンバーの気分を格納
      @niko_faces[user.name] = faces
    end

    # チームの気分を判定する
    @days.each do |day|
      faces = Array.new
      @users.each do|user|
        faces << @niko_faces[user.name][day]
      end
      faces.compact!
      if faces.size != 0
        faces.each do |face|
          @team_feelings[day.day] += face.feeling
        end
        @team_feelings[day.day] /= faces.size
        @team_feelings[day.day] = @team_feelings[day.day].truncate.to_i
      else
        @team_feelings[day.day] = nil
      end
    end
  end
end

