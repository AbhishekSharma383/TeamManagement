class Team < ApplicationRecord
    belongs_to :owner, class_name: 'User'
    has_many :team_memberships, dependent: :destroy
    has_many :members, through: :team_memberships, source: :user
  
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
  
    scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") if name.present? }
  end
  