require "rails_helper"

RSpec.describe "Doctors::Availabilities", type: :request do
  describe "GET /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }
    let(:availabilities_params) do
      {
        availability_range: 'mock_availability_range',
        slots_range: 'mock_slots_range',
        slots_step: 'mock_slots_step',
        slots_offset: 'mock_slots_offset',
        slots_limit: 'mock_slots_limit',
        doctor: doctor
      }
    end

    before do
      allow(Doctors::AvailabilityQuery).to receive(:new).with(ActionController::Parameters.new(availabilities_params).permit!) { double(call: []) }
    end

    it "returns list of availabilities" do
      get doctor_availabilities_path(doctor), params: { availabilities: availabilities_params }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['availabilities']).to be_empty
    end
  end
end

