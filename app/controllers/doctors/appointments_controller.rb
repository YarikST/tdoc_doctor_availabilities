class Doctors::AppointmentsController < ApplicationController
  before_action :find_doctor
  before_action :find_patient
  before_action :find_appointment, only: [:update, :destroy]

  def index
    render :index, locals: { appointments: @patient.appointments }
  end

  def create
    create_appointment(appointment_params)

    if @appointment.save
      render :show, locals: { appointment: @appointment }, status: :created
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @appointment.update(appointment_params)
      render :show, locals: { appointment: @appointment }
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.destroy
    head :ok
  end

  private

  def appointment_params
    params.require(:appointment).permit(:start_at, :end_at, :wday, :disease).merge(patient: @patient)
  end

  def create_appointment(params)
    @appointment = @doctor.appointments.new(params)
  end

  def find_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end

  def find_patient
    @patient = Patient.find(params[:patient_id])
  end

  def find_appointment
    @appointment = Appointment.find(params[:id])
  end
end
