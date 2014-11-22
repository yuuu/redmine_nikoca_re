class AddUnreadToNikoResponses < ActiveRecord::Migration
  def up
    add_column :niko_responses, :unread, :boolean
  end
end
