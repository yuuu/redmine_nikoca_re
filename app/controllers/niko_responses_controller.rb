# Redmine_Nikoca_Re プラグイン NikoResponsesController
# @author yuuu(Yuhei Okazaki)

# レスポンスの作成・編集・表示などのアクション処理を実装
# @abstract NikoResponseのアクションに応じた処理を定義
class NikoResponsesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project
  before_filter :find_niko_face

  # レスポンス一覧を表示する
  def index
    redirect_to project_niko_face_path(@project, @niko_face.id)
  end

  # レスポンスを作成する
  def create
    @niko_response = NikoResponse.new(params[:niko_response])
    @niko_response.author = User.current
    @niko_response.unread = true
    if @niko_response.valid?
      @niko_face.responses << @niko_response
      NikoMailer.deliver_add_response(@niko_face, @niko_response)
      redirect_to project_niko_face_path(@project, @niko_face.id)
    else
      render 'niko_faces/show'
    end
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
    @niko_face = NikoFace.find(params[:niko_face_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
