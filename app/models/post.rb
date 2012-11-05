class Post
  include Mongoid::Document
  field :url, type: String
  field :title, type: String
  field :location, type: String
  field :description, type: String
  field :linkedJobs, type: Array
end
