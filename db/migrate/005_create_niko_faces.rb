class CreateNikoFaces < ActiveRecord::Migration
  def change
    create_table :niko_faces do |t|
      t.integer :author_id
      t.date :date
      t.text :comment
      t.integer :feeling
      t.timestamps
    end
  end
end
