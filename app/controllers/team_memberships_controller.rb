class TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :authorize_team_owner, only: [:create, :destroy]
  before_action :authorize_team_member, only: [:index, :show]

  # POST /teams/:team_id/memberships
  def create
    member_emails = params[:member_emails]

    # Find users by emails
    users = User.where(email: member_emails)
    
    if users.empty?
      return render json: { error: 'No users found with the provided emails' }, status: :not_found
    end

    # Add users to the team
    @team.members << users

    # Respond with the added users
    render json: users, status: :created
  end

  # DELETE /teams/:team_id/memberships/:id
  def destroy
    member = @team.members.find_by(id: params[:id])

    if member.nil?
      return render json: { error: 'User is not a member of the team' }, status: :not_found
    end

    # Remove member from the team
    @team.members.destroy(member)
    head :no_content
  end

  # GET /teams/:team_id/memberships
  def index
    members = @team.members.by_last_name(params[:last_name]).page(params[:page]).per(10)
    render json: members, status: :ok
  end

  # GET /teams/:team_id/memberships/:id
  def show
    member = @team.members.find_by(id: params[:id])

    if member.nil?
      return render json: { error: 'User is not a member of the team' }, status: :not_found
    end

    render json: member, status: :ok
  end

  private

  def set_team
    @team = Team.find_by(id: params[:team_id])
    render json: { error: 'Team not found' }, status: :not_found if @team.nil?
  end

  def authorize_team_owner
    unless @team.owner == current_user
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end

  def authorize_team_member
    unless @team.owner == current_user || @team.members.include?(current_user)
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end
  
end
