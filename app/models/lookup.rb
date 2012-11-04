class Lookup < ActiveRecord::Base
  validates_uniqueness_of :domain
  validates_presence_of :domain, :title, :description
end
