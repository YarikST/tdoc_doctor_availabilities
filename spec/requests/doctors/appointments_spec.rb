require "rails_helper"

RSpec.describe "Doctors::Appointments", type: :request do
  describe "GET /doctors/:doctor_id/appointments" do
    let(:patient) { create(:patient) }
    let(:appointment) { create(:appointment, patient:) }

    it "returns list of appointments" do
      get "/doctors/#{appointment.doctor.id}/appointments", params: { patient_id: patient.id }, headers: {"Content-Type" => "application/json"}

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['appointments']).to contain_exactly(a_hash_including({ "id" => appointment.id }))
    end
  end

  describe "POST /doctors/:doctor_id/appointments" do
    let(:patient) { create(:patient) }
    let(:doctor) { create(:doctor) }
    let(:appointment_attr) { build(:appointment, patient:, doctor:) }

    context "when success" do
      it "returns created appointment" do
        post "/doctors/#{doctor.id}/appointments", params: { patient_id: patient.id, appointment: appointment_attr}.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['appointment']).to a_hash_including({ "doctor_id" => appointment_attr.doctor_id })
      end
    end

    context "when failed" do
      it "returns error" do
        post "/doctors/#{doctor.id}/appointments", params: { patient_id: patient.id, appointment: { wday: nil } }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Start at can't be blank", "End at can't be blank", "Wday can't be blank", "Disease can't be blank")
      end
    end
  end

  describe "PUT /doctors/:doctor_id/appointments" do
    let(:patient) { create(:patient) }
    let(:appointment) { create(:appointment, patient:) }

    context "when success" do
      it "returns updated appointments" do
        put "/doctors/#{appointment.doctor.id}/appointments/#{appointment.id}", params: {
          patient_id: patient.id, appointment: { wday: 3 }
        }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['appointment']).to a_hash_including({ "id" => appointment.id, "wday" => 3 })
      end
    end

    context "when failed" do
      it "returns error" do
        put "/doctors/#{appointment.doctor.id}/appointments/#{appointment.id}", params: {
          patient_id: patient.id, appointment: { wday: nil }
        }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to contain_exactly("Wday can't be blank")
      end
    end
  end

  describe "DELETE /doctors/:doctor_id/appointments" do
    let(:patient) { create(:patient) }
    let(:appointment) { create(:appointment, patient:) }

    context "when success" do
      it "destroys appointments" do
        delete "/doctors/#{appointment.doctor.id}/appointments/#{appointment.id}", params: { patient_id: patient.id }.to_json, headers: {"Content-Type" => "application/json"}

        expect(response).to have_http_status(:ok)
        expect(Appointment.find_by(id: appointment.id)).to be(nil)
      end
    end
  end
end

