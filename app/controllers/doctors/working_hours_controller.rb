class Doctors::WorkingHoursController < ApplicationController
  before_action :find_doctor
  before_action :find_working_hours, except: [:index, :create]

  def index
    render :index, locals: { working_hours: @doctor.working_hours }
  end

  def create
    create_working_hours(working_hours_params)

    if @working_hours.save
      render :show, locals: { working_hours: @doctor.working_hours }, status: :created
    else
      render json: { errors: @working_hours.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @working_hours.update(working_hours_params)
      render :show, locals: { working_hours: @doctor.working_hours }
    else
      render json: { errors: @working_hours.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @working_hours.destroy
    head :ok
  end

  private

  def working_hours_params
    params.require(:working_hours).permit(:start_at, :end_at, :wday)
  end

  def create_working_hours(params)
    @working_hours = @doctor.working_hours.new(params)
  end

  def find_doctor
    @doctor = Doctor.find(params[:doctor_id])
  end

  def find_working_hours
    @working_hours = @doctor.working_hours.find(params[:id])
  end
end
