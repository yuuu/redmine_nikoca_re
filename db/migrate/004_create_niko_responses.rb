class CreateNikoResponses < ActiveRecord::Migration
  def change
    create_table :niko_responses do |t|
      t.integer :author_id
      t.integer :niko_face_id
      t.text :comment
      t.timestamps
    end
  end
end
