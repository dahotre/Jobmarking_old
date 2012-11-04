class RemoveColumnRequirementFromLookups < ActiveRecord::Migration
  def up
    remove_column :lookups, :requirement
  end

  def down
    add_column :lookups, :requirement, :string
  end
end
