class Doctors::AvailabilitiesController < ApplicationController
  before_action :find_doctor

  def index
    availabilities = Doctors::AvailabilityQuery.new(availabilities_params).call

    render :index, locals: { availabilities: availabilities }
  end

  private

  def availabilities_params
    params.require(:availabilities)
          .permit(:availability_range, :slots_range, :slots_step, :slots_offset, :slots_limit)
          .merge(doctor: @doctor)
  end

  def find_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end
end
