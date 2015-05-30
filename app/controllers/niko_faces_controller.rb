# Redmine_Nikoca_Re プラグイン NikoFacesController
# @author yuuu(Yuhei Okazaki)

# @abstract Dateクラスにdaysメソッドを拡張
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

# ニコカレの作成・編集・表示などのアクション処理を実装
# @abstract NikoFaceのアクションに応じた処理を定義
class NikoFacesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project, :authorize
  before_filter :find_niko_face, :except => [:backnumber, :index, :new, :create]

  # カレンダ構築に必要な情報をセット
  before_filter :only => [:backnumber, :index] do
    @backnumber = 0
    @backnumber = params[:id].to_i if params[:id].to_i
    @dates = get_dates(@backnumber)
    @users = get_users(@project)
    @niko_faces = NikoFace.project_member_faces(@project, @dates)
    @team_feelings = NikoFace.team_feelings(@project, @dates)
  end

  # 1周間の日数
  DAY_OF_WEEK = 7

  # カレンダに表示する期間(単位：週)
  DISP_WEEK_NUM = 2

  # カレンダに表示する日数
  DISP_DAY_NUM = DISP_WEEK_NUM * DAY_OF_WEEK

  # ニコカレのカレンダー(バックナンバー)を表示する
  def backnumber
  end

  # ニコカレのカレンダーを表示する
  def index
		days = params[:days]
		if days != nil
			@date = Date.today - days.to_i
			@niko_faces = NikoFace.project_member_faces(@project, [@date])
			@team_feelings = NikoFace.team_feelings(@project, [@date])
		else
			@date = nil
		end
  end

  # ニコカレの作成画面を表示する
  def new
    niko_faces = NikoFace.where(:author_id => User.current.id).where(:date => Date.today);

    if niko_faces[0] == nil
      @niko_face = NikoFace.new
    else
      @niko_face = niko_faces[0]
      redirect_to edit_project_niko_face_path(@project, @niko_face.id)
    end
  end

  # ニコカレを作成する
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

  # ニコカレの詳細画面を表示する
  def show
    # レスをすべて既読とする
    @niko_face.read_responses(User.current)

    # レス投稿用オブジェクト
    @niko_response = NikoResponse.new
  end

  # ニコカレの編集画面を表示する
  def edit
  end

  # ニコカレを削除する
  def destroy
    @niko_face.destroy
    redirect_to project_niko_faces_path(@project)
  end

  # ニコカレを更新する
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
  # 現在のプロジェクトを@projectへセットする
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # 現在のニコカレを@niko_faceへセットする
  def find_niko_face
    @niko_face = NikoFace.find_by_id(params["id"])
    render_404    unless @niko_face
  end

  # カレンダーに表示する日付リストを取得
  # @param backnumber [Fixnum] バックナンバー.
  # 0が最新で数値が大きくなるほど過去を示す.
  # @return [Array] 日付リスト
  def get_dates(backnumber)
    date = Date.today - (DISP_DAY_NUM * (backnumber + 1)) + 1
    dates = Date.days(date, DISP_DAY_NUM)
    return dates
  end

  # プロジェクトに属するユーザリストを取得
  # @param project [Project] カレントプロジェクト
  # @return [Array] ユーザリスト
  def get_users(project)
    users = Array.new
    project.members.each do |member|
      users << member.user
    end
    return users
  end
end
