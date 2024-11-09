Rails.application.routes.draw do

  devise_for :users

  resources :teams do
    # Nested routes for 'team_memberships' under 'teams'
    resources :team_memberships, path: 'members', only: [:create, :destroy, :index], controller: 'team_memberships'
  end
  
end

