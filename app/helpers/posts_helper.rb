module PostsHelper
  def self.createPost job
    post = Post.find_or_initialize_by(url: job.acturl)
    if post.title.blank?
      post.title = job.title
    end
    if post.description.blank?
      post.description = job.description
    end
    if post.location.blank?
      post.location = job.location
    end
    if post.linkedJobs.blank?
      post.add_to_set(:linkedJobs, job.id)
    end
    post.save
    Rails.logger.debug '-----------------------'
  end
end
