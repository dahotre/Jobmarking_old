class Lookup < ActiveRecord::Base
  validates_uniqueness_of :domain
  validates_presence_of :domain, :title, :description

  attr_accessible :domain, :title, :description, :location, :otherDomainHits, :deleted
end
