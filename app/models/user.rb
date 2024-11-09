class User < ApplicationRecord
  has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_id', dependent: :destroy
  has_many :team_memberships, dependent: :destroy
  has_many :teams, through: :team_memberships

  # Devise configuration
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
