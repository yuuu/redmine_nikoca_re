Redmine::Plugin.register :redmine_nikoca_re do
  name 'Redmine Nikoca Re plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  project_module :redmine_nikoca_re do
    permission :view_redmine_nikoca_re, :niko_faces => [:index, :show]
    permission :manage_redmine_nikoca_re, :niko_faces => [:new, :edit, :create, :update, :destroy],
               :require => :member
  end

  menu :project_menu, :redmine_nikoca_re, { :controller => 'niko_faces', :action => 'index'}, :param => :project_id
end
