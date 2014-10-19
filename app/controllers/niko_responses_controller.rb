class NikoResponsesController < ApplicationController
  unloadable
  menu_item :redmine_nikoca_re
  before_filter :find_project
  before_filter :find_niko_face


  def create
    @niko_response = NikoResponse.new(params[:niko_response])
    @niko_response.author = User.current
    @niko_face.responses << @niko_response

    redirect_to project_niko_face_path(@project, @niko_face.id)
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_niko_face
    @niko_face = NikoFace.find(params[:niko_face_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
