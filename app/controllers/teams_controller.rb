class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :update, :destroy]
  before_action :authorize_team_owner, only: [:update, :destroy]

  # POST /teams
  def create
    # Build a new team for the current user (owner)
    @team = current_user.owned_teams.build(team_params)

    if @team.save
      # Add initial members if provided
      add_initial_members_by_email(@team, params[:member_emails]) if params[:member_emails].present?
      render json: { team: @team, members: @team.members }, status: :created
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /teams
  def index
    # Optionally filter by name and paginate the result
    @teams = Team.by_name(params[:name])
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(params[:per_page] || 10)

    if @teams.any?
      render json: @teams, status: :ok
    else
      render json: { message: 'No teams found' }, status: :not_found
    end
  end

  # GET /teams/:id
  def show
    render json: @team, status: :ok
  end

  # PATCH /teams/:id
  def update
    # Only allow updates for name and description
    if @team.update(team_params)
      render json: @team, status: :ok
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /teams/:id
  def destroy
    # Only the owner can destroy the team
    @team.destroy
    head :no_content
  end

  private

  # Adds initial members to the team by email
  def add_initial_members_by_email(team, member_emails)
    users = User.where(email: member_emails)
    team.members << users
  end

  # Sets the team based on the provided ID
  def set_team
    @team = Team.find_by(id: params[:id])
    render json: { error: 'Team not found' }, status: :not_found if @team.nil?
  end

  # Checks if the current user is the owner of the team
  def authorize_team_owner
    render json: { error: 'Unauthorized' }, status: :forbidden unless @team.owner == current_user
  end

  # Strong parameters for team name and description
  def team_params
    params.require(:team).permit(:name, :description)
  end
end
