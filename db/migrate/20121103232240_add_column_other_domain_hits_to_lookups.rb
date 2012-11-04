class AddColumnOtherDomainHitsToLookups < ActiveRecord::Migration
  def up
    add_column :lookups, :otherDomainHits, :integer
  end

  def down
    remove_column :lookups, :otherDomainHits
  end
end
