require 'rails_helper'

RSpec.describe "Teams API", type: :request do
  # Pagination test
  describe "GET /teams with pagination" do
    it "returns paginated teams" do
      create_list(:team, 15) # Using FactoryBot to create teams
      get "/teams", params: { page: 1, per_page: 10 }
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(10)
    end
  end

  # Not found error test
  describe "GET /teams/:id when team does not exist" do
    it "returns a 404 not found error" do
      get "/teams/999"
      
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Couldn't find Team with 'id'=999")
    end
  end

  # Unauthorized access test
  describe "PATCH /teams/:id without authorization" do
    it "returns a 403 forbidden error" do
      team = create(:team, owner: another_user)
      patch "/teams/#{team.id}", params: { name: "Updated Name" }, headers: { "Authorization" => token_for(user) }
      
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("You are not authorized to perform this action")
    end
  end
end
