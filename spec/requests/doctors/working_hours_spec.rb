require "rails_helper"

RSpec.describe "Doctors::WorkingHours", type: :request do
  describe "GET /doctors/:doctor_id/working_hours" do
    let(:doctor) { create(:doctor) }
    let!(:working_hour) { create(:working_hour, doctor: doctor) }
    let!(:working_hour2) { create(:working_hour) }

    it "returns list of working_hours" do
      get doctor_working_hours_path(doctor)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "id" => working_hour.id }))
    end
  end

  describe "POST /doctors/:doctor_id/working_hours" do
    let(:doctor) { create(:doctor) }
    let(:working_hour_attr) { build(:working_hour, doctor: doctor) }

    context "when success" do
      it "returns created working_hours" do
        post doctor_working_hours_path(doctor), params: { working_hours: working_hour_attr }, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "doctor_id" => working_hour_attr.doctor_id }))
      end
    end

    context "when failed" do
      it "returns error" do
        post doctor_working_hours_path(doctor), params: { working_hours: { wday: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Start at can't be blank", "End at can't be blank", "Wday can't be blank")
      end
    end
  end

  describe "PUT /doctors/:doctor_id/working_hours" do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor) }

    context "when success" do
      it "returns updated working_hours" do
        put doctor_working_hour_path(doctor, working_hour), params: { working_hours: { wday: 3 } }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['working_hours']).to contain_exactly(a_hash_including({ "id" => working_hour.id, "wday" => 3 }))
      end
    end

    context "when failed" do
      it "returns error" do
        put doctor_working_hour_path(doctor, working_hour), params: { working_hours: { wday: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Wday can't be blank")
      end
    end
  end

  describe "DELETE /doctors/:doctor_id/working_hours" do
    let(:doctor) { create(:doctor) }
    let(:working_hour) { create(:working_hour, doctor: doctor) }

    context "when success" do
      it "destroys working_hours" do
        delete doctor_working_hour_path(doctor, working_hour)

        expect(response).to have_http_status(:ok)
        expect(WorkingHour.find_by(id: working_hour.id)).to be(nil)
      end
    end
  end
end

