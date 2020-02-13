class AddUnreadToNikoResponses < ActiveRecord::Migration[4.2]
  def up
    add_column :niko_responses, :unread, :boolean
  end
end
