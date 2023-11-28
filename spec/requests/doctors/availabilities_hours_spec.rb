require "rails_helper"

RSpec.describe "Doctors::Availabilities", type: :request do
  describe "GET /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }

    before do
      allow(Doctors::AvailabilityQuery).to receive(:new).with( ActionController::Parameters.new(
        availability_range: 'availability_range', slots_range: 'slots_range', slots_step: 'slots_step',
        slots_offset: 'slots_offset', slots_limit: 'slots_limit', doctor:).permit!
      ) { double(call: []) }
    end

    it "returns list of availabilities" do
      get "/doctors/#{doctor.id}/availabilities", params: {
        availabilities: {
          availability_range: 'availability_range', slots_range: 'slots_range', slots_step: 'slots_step',
          slots_offset: 'slots_offset', slots_limit: 'slots_limit'
        }
      }, headers: {"Content-Type" => "application/json"}

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['availabilities']).to be_empty
    end
  end
end

