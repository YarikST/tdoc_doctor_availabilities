require "rails_helper"

RSpec.describe "Doctors::Availabilities", type: :request do
  describe "GET /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }
    let!(:working_hour) { create(:working_hour, doctor: doctor) }
    let!(:working_hour2) { create(:working_hour) }

    it "returns list of working_hours" do
      get "/doctors/#{doctor.id}/availabilities", params: {}, headers: {"Content-Type" => "application/json"}

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "id" => working_hour.id }))
    end
  end

  describe "POST /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }
    let(:working_hour_attr) { build(:working_hour, doctor: doctor) }

    context "when success" do
      it "returns created working_hours" do
        post "/doctors/#{doctor.id}/availabilities", params: { working_hours: working_hour_attr }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "doctor_id" => working_hour_attr.doctor_id }))
      end
    end

    context "when failed" do
      it "returns error" do
        post "/doctors/#{doctor.id}/availabilities", params: { working_hours: { wday: nil } }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Start at can't be blank", "End at can't be blank", "Wday can't be blank")
      end
    end
  end

  describe "PUT /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor) }

    context "when success" do
      it "returns updated working_hours" do
        put "/doctors/#{doctor.id}/availabilities/#{working_hour.id}", params: { working_hours: { wday: 3 } }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "id" => working_hour.id, "wday" => 3 }))
      end
    end

    context "when failed" do
      it "returns error" do
        put "/doctors/#{doctor.id}/availabilities/#{working_hour.id}", params: { working_hours: { wday: '' } }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Wday can't be blank")
      end
    end
  end

  describe "DELETE /doctors/:doctor_id/availabilities" do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor) }

    context "when success" do
      it "destroys working_hours" do
        delete "/doctors/#{doctor.id}/availabilities/#{working_hour.id}", params: {}.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)
        expect(WorkingHour.find_by(id: working_hour.id)).to be(nil)
      end
    end
  end
end

