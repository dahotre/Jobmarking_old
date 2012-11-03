class CreateLookups < ActiveRecord::Migration
  def change
    create_table :lookups do |t|
      t.string :domain
      t.string :title
      t.string :description
      t.string :requirement
      t.boolean :deleted, :default => false
      t.string :location
      t.timestamps
    end
  end
end
