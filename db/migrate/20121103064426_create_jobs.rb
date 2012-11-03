class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :url
      t.references :user
      t.string :title
      t.text :description
      t.string :location
      t.string :acturl
      t.string :status, :default => 'A'
      t.string :warn

      t.timestamps
    end
  end
end
