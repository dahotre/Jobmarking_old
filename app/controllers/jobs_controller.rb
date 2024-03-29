class JobsController < ApplicationController
  before_filter :require_login

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.paginate_by_sql(['select * from jobs where user_id = ? order by id desc', current_user.id],
                                :page => params[:page], :per_page => 5)
    @job = Job.new

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render :json => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(params[:job])

    ## Ensuring that same url has not been used by the same user before
    if !params[:job][:url].blank? and Job.find(:first, :conditions => { :user_id => current_user.id, :url => params[:job][:url].strip})
      @job.errors.add_to_base 'Job already added.'
      respond_to do |format|
        format.html { render :action => "new"}
        format.js
      end
    else
      @job.user_id = current_user.id
      logger.debug 'Job in controller..'
      respond_to do |format|
        if @job.save
          logger.debug 'out of save'
          begin
            PostsHelper.createPost @job
          rescue  Exception => e
            logger.error e.message
          end
          format.html { redirect_to(@job, :notice => 'Job was successfully created.') }
          format.json { render :json => @job, :status => :created, :location => @job }
          format.js
        else
          logger.error 'error in save..'
          logger.error @job.errors
          format.html { render :action => "new" }
          format.json { render :json => @job.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    @job = Job.find(params[:id])
    if @job.user_id.eql? current_user.id
      respond_to do |format|
        if @job.update_attributes(params[:job])
          format.html { render :action => "edit", :notice => 'Job was successfully updated.' }
          format.json { head :no_content }
          format.js
        else
          format.html { render :action => "edit" }
          format.json { render :json => @job.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    else
      not_authenticated
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    logger.debug 'in destroy'
    @job = Job.find(params[:id])
    @job.destroy if @job.user_id.eql? current_user.id

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.json { head :no_content }
      format.js
    end
  end

  def refresh
    logger.info 'in refresh'
    newJob = Job.new
    @job = Job.find(params[:id])
    newJob.url= @job.url
    newJob.redirectAndParse
    diffHash = Hash.new

    # Add other diffs if necessary
    unless @job.description.blank? and newJob.description.blank?
      diffHash["description"] = Diffy::Diff.new(@job.description, newJob.description).to_s(:html)

      @job.diffHash = diffHash
      @job.newDesc = newJob.description
    end

    respond_to do |format|
      format.html { render :action => "edit", :notice => 'Job Details refreshed.' }
      format.js
    end

  end
end