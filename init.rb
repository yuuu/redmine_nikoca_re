Redmine::Plugin.register :redmine_nikoca_re do
  name 'Redmine Nikoca Re plugin'
  author 'Yuuu'
  description 'This is a plugin to check every day the mood condition of project members.'
  version '0.2.0'
  url 'https://github.com/yuuu/redmine_nikoca_re'
  author_url 'http://ylgbk.hatenablog.com/'

  project_module :redmine_nikoca_re do
    permission :view_redmine_nikoca_re, :niko_faces => [:index, :show, :backnumber]
    permission :manage_redmine_nikoca_re, :niko_faces => [:new, :edit, :create, :update, :destroy, :backnumber],
               :require => :member
  end

  menu :project_menu, :redmine_nikoca_re, { :controller => 'niko_faces', :action => 'index'}, :param => :project_id
end
