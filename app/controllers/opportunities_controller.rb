class OpportunitiesController < ApplicationController
  before_action :lookup_team, only: [:activate, :deactivate, :new, :create, :edit, :update, :visit]
  before_action :lookup_opportunity, only: [:edit, :update, :activate, :deactivate, :visit]
  before_action :cleanup_params_to_prevent_tagging_error
  before_action :validate_permissions, only: [:new, :edit, :create, :update, :activate, :deactivate]
  before_action :verify_payment, only: [:new, :create]
  before_action :stringify_location, only: [:create, :update]

  # POST                  /teams/:team_id/opportunities/:id/apply(.:format)
  def apply
    redirect_to_signup_if_unauthenticated(request.referer, "You must login/signup to apply for an opportunity") do
      job = Opportunity.find(params[:id])
      if current_user.apply_to(job)
        NotifierMailer.new_applicant(current_user.id, job.id).deliver!
        record_event('applied to job', job_public_id: job.public_id, 'job team' => job.team.slug)
        respond_to do |format|
          format.html { redirect_to :back, notice: "Your resume has been submitted for this job!"}
          format.json { head :ok }
        end
      end
    end
  end

  # GET                   /teams/:team_id/opportunities/new(.:format)
  def new
    team_id = params[:team_id]
    @job = Opportunity.new(team_id: team_id)
  end

  # GET                   /teams/:team_id/opportunities/:id/edit(.:format)
  def edit
  end

  # POST                  /teams/:team_id/opportunities(.:format)
  def create
    opportunity_create_params = params.require(:opportunity).permit(:name, :team_id, :opportunity_type, :description, :tag_list, :location, :link, :salary, :apply, :remote)
    @job = Opportunity.new(opportunity_create_params)
    respond_to do |format|
      if @job.save
        format.html { redirect_to teamname_path(@team.slug), notice: "#{@job.name} added" }
      else
        flash[:error] = @job.errors.full_messages.blank? ? "There was an issue with your account, please contact support@coderwall.com" : nil
        format.html { render action: "new" }
      end
    end
  end

  # PUT                   /teams/:team_id/opportunities/:id(.:format)
  def update
    opportunity_update_params = params.require(:opportunity).permit(:id, :name, :team_id, :opportunity_type, :description, :tag_list, :location, :link, :salary, :apply)
    respond_to do |format|
      if @job.update_attributes(opportunity_update_params)
        format.html { redirect_to teamname_path(@team.slug), notice: "#{@job.name} updated" }
      else
        format.html { render action: "new" }
      end
    end
  end

  # GET                   /teams/:team_id/opportunities/:id/activate(.:format)
  def activate
    @job.activate!
    header_ok
  end

  # GET                   /teams/:team_id/opportunities/:id/deactivate(.:format)
  def deactivate
    @job.deactivate!
    header_ok
  end

  # POST                  /teams/:team_id/opportunities/:id/visit(.:format)
  def visit
    unless is_admin?
      viewing_user.track_opportunity_view!(@job) if viewing_user
      @job.viewed_by(viewing_user || session_id)
    end
    header_ok
  end
  
  # GET                   /jobs(/:location(/:skill))(.:format)
  def index
    current_user.seen(:jobs) if signed_in?
    store_location! unless signed_in?
    chosen_location = (params[:location] || closest_to_user(current_user)).try(:titleize)
    chosen_location = nil if chosen_location == 'Worldwide'
    @remote_allowed = params[:remote]     == 'true'

    @page = params[:page].try(:to_i) || 1
    tag = params[:skill].gsub(/\-/, ' ').downcase unless params[:skill].nil?

    @jobs = get_jobs_for(chosen_location, tag, @page, params[:q], @remote_allowed)
    @jobs_left = @jobs.count
    @jobs = @jobs.limit(20)

    chosen_location = 'Worldwide' if chosen_location.nil?
    @locations = Rails.cache.fetch("job_locations_#{params[:location]}_#{params[:skill]}", expires_in: 1.hour) do
      Opportunity.by_tag(tag).flat_map(&:locations).reject { |loc| loc == "Worldwide" }.uniq.sort.compact
    end
    # @locations.delete(chosen_location) unless @locations.frozen?
    params[:location] = chosen_location
    @lat, @lng = geocode_location(chosen_location)

    respond_to do |format|
      format.html { render layout: 'coderwallv2' }
      format.json { render json: @jobs.map(&:to_public_hash) }
      format.js
    end

  end

  # GET                   /jobs-map(.:format)
  def map
    @job_locations = all_job_locations
    @job_skills = all_job_skills
  end

  private

  def validate_permissions
    redirect_to(:back, flash:{error: 'This feature is available only for the team admin'}) unless team_admin?
  end

  def team_admin?
    is_admin? || @team.admin?(current_user)
  end

  def lookup_team
    @team = Team.find(params[:team_id])
  end

  def lookup_opportunity
    @job = Opportunity.find(params[:id])
  end

  def header_ok
    respond_to do |format|
      format.json { head :ok }
    end
  end

  def cleanup_params_to_prevent_tagging_error
    if params[:opportunity] && params[:opportunity][:tag_list]
      params[:opportunity][:tag_list] = "#{params[:opportunity][:tag_list]}".split(',').map(&:strip).reject(&:empty?).join(",")
      params[:opportunity][:tag_list] = nil if params[:opportunity][:tag_list].strip.blank?
    end
  end

  def verify_payment
    redirect_to employers_path unless @team.can_post_job?
  end

  def stringify_location
    params[:opportunity][:location] = params[:opportunity][:location].is_a?(Array) ? params[:opportunity][:location].join("|") : params[:opportunity][:location]
  end

  def all_job_locations
    Rails.cache.fetch('job_locations', expires_in: 23.hours) { Opportunity.all.flat_map(&:locations).push("Worldwide").uniq.compact }
  end

  def all_job_skills
    Rails.cache.fetch('job_skills', expires_in: 23.hours) { Opportunity.all.flat_map(&:tag_list).uniq.compact }
  end

  def closest_to_user(user)
    unless user.nil?
      all_job_locations.include?(user.city) ? user.city : nil
    end
  end

  def geocode_location(location)
    Rails.cache.fetch("geocoded_location_of_#{location}") { User.where('LOWER(city) = ?', location.downcase).map { |u| [u.lat, u.lng] }.first || [0.0, 0.0] }
  end

  def get_jobs_for(chosen_location, tag, page, query = nil, remote_allowed = false)
    scope = Opportunity

    escaped_query = query.nil? ? query : Regexp.escape(query)

    if remote_allowed
      scope = scope.where(remote: true)
    else
      scope = scope.by_city(chosen_location) if chosen_location && chosen_location.length > 0
    end

    scope = scope.by_tag(tag) unless tag.nil?
    scope = scope.by_query(escaped_query) if escaped_query
    # TODO: Verify that there are no unmigrated teams
    scope = scope.where('team_id is not null')
    scope.offset((page-1) * 20)
  end
end
