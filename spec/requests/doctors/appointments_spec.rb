require "rails_helper"

RSpec.describe "Doctors::Appointments", type: :request do
  describe "GET /doctors/:doctor_id/appointments" do
    let(:appointment) { create(:appointment) }

    it "returns list of appointments" do
      get doctor_appointments_path(appointment.doctor)

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
        post doctor_appointments_path(doctor), params: { appointment: appointment_attr }, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['appointment']).to a_hash_including({ "doctor_id" => appointment_attr.doctor_id })
      end
    end

    context "when failed" do
      it "returns error" do
        post doctor_appointments_path(doctor), params: { appointment: { patient_id: patient.id, wday: nil } }

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
        put doctor_appointment_path(appointment.doctor, appointment), params: { appointment: { wday: 3 } }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['appointment']).to a_hash_including({ "id" => appointment.id, "wday" => 3 })
      end
    end

    context "when failed" do
      it "returns error" do
        put doctor_appointment_path(appointment.doctor, appointment), params: { appointment: { wday: nil } }

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
        delete doctor_appointment_path(appointment.doctor, appointment)

        expect(response).to have_http_status(:ok)
        expect(Appointment.find_by(id: appointment.id)).to be(nil)
      end
    end
  end
end

