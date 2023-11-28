require "rails_helper"

describe Doctors::AvailabilityQuery do
  let(:doctor) { create(:doctor) }
  let(:patient) { create(:patient) }

  let(:monday_at) { DateTime.parse("2023-11-27T09:00:00+00:00") }
  let!(:working_hour_monday1) { create(:working_hour, doctor:, wday: monday_at.wday, start_at: monday_at, end_at: monday_at + 4.hours ) }
  let!(:working_hour_monday2) { create(:working_hour, doctor:, wday: monday_at.wday, start_at: monday_at + 5.hours, end_at: monday_at + 9.hours ) }

  let(:tuesday_at) { DateTime.parse("2023-11-28T09:00:00+00:00") }
  let!(:working_hour_tuesday1) { create(:working_hour, doctor:, wday: tuesday_at.wday, start_at: tuesday_at, end_at: tuesday_at + 4.hours ) }
  let!(:working_hour_tuesday2) { create(:working_hour, doctor:, wday: tuesday_at.wday, start_at: tuesday_at + 5.hours, end_at: tuesday_at + 9.hours ) }

  let(:availability_range) { 'week' }
  let(:slots_range) { 'all' }
  let(:slots_step) { '1' }
  let(:slots_offset) { nil }
  let(:slots_limit) { nil }

  let(:filters) do
    {
      doctor:,
      availability_range:,
      slots_range:,
      slots_step:,
      slots_offset:,
      slots_limit:,
    }.with_indifferent_access
  end

  subject(:call) { described_class.new(filters).call }

  def slots(availabilities)
    availabilities.map do |availability|
      {
        start: availability['slot_start_at'].to_s,
        end: availability['slot_end_at'].to_s,
        dow: availability['slot_dow']
      }
    end
  end

  before do
    doctor = create(:doctor)
    patient = create(:patient)
    date_at = DateTime.parse("2023-11-27T09:00:00+00:00")
    working_hour = create(:working_hour, doctor:, wday: date_at.wday, start_at: date_at, end_at: date_at + 4.hours )
    appointment = create(:appointment, doctor:, patient:, wday: date_at.wday, start_at: date_at, end_at: date_at + 2.hours)
  end

  it "returns doctors availabilities" do
    slots = slots(call)

    expect(call.size).to eq(16)
    expect(slots[0]).to include({:start=>"2023-11-27 09:00:00 UTC", :end=>"2023-11-27 10:00:00 UTC", :dow=>1})
    expect(slots[1]).to include({:start=>"2023-11-27 10:00:00 UTC", :end=>"2023-11-27 11:00:00 UTC", :dow=>1})
    expect(slots[2]).to include({:start=>"2023-11-27 11:00:00 UTC", :end=>"2023-11-27 12:00:00 UTC", :dow=>1})
    expect(slots[3]).to include({:start=>"2023-11-27 12:00:00 UTC", :end=>"2023-11-27 13:00:00 UTC", :dow=>1})
    expect(slots[4]).to include({:start=>"2023-11-27 14:00:00 UTC", :end=>"2023-11-27 15:00:00 UTC", :dow=>1})
    expect(slots[5]).to include({:start=>"2023-11-27 15:00:00 UTC", :end=>"2023-11-27 16:00:00 UTC", :dow=>1})
    expect(slots[6]).to include({:start=>"2023-11-27 16:00:00 UTC", :end=>"2023-11-27 17:00:00 UTC", :dow=>1})
    expect(slots[7]).to include({:start=>"2023-11-27 17:00:00 UTC", :end=>"2023-11-27 18:00:00 UTC", :dow=>1})

    expect(slots[8]).to include({:start=>"2023-11-28 09:00:00 UTC", :end=>"2023-11-28 10:00:00 UTC", :dow=>2})
    expect(slots[9]).to include({:start=>"2023-11-28 10:00:00 UTC", :end=>"2023-11-28 11:00:00 UTC", :dow=>2})
    expect(slots[10]).to include({:start=>"2023-11-28 11:00:00 UTC", :end=>"2023-11-28 12:00:00 UTC", :dow=>2})
    expect(slots[11]).to include({:start=>"2023-11-28 12:00:00 UTC", :end=>"2023-11-28 13:00:00 UTC", :dow=>2})
    expect(slots[12]).to include({:start=>"2023-11-28 14:00:00 UTC", :end=>"2023-11-28 15:00:00 UTC", :dow=>2})
    expect(slots[13]).to include({:start=>"2023-11-28 15:00:00 UTC", :end=>"2023-11-28 16:00:00 UTC", :dow=>2})
    expect(slots[14]).to include({:start=>"2023-11-28 16:00:00 UTC", :end=>"2023-11-28 17:00:00 UTC", :dow=>2})
    expect(slots[15]).to include({:start=>"2023-11-28 17:00:00 UTC", :end=>"2023-11-28 18:00:00 UTC", :dow=>2})
  end

  context 'when asap' do
    let(:slots_range) { 'asap' }

    it "returns doctors availabilities" do
      slots = slots(call)

      expect(call.size).to eq(2)
      expect(slots[0]).to include({:start=>"2023-11-27 09:00:00 UTC", :end=>"2023-11-27 10:00:00 UTC", :dow=>1})
      expect(slots[1]).to include({:start=>"2023-11-28 09:00:00 UTC", :end=>"2023-11-28 10:00:00 UTC", :dow=>2})
    end
  end

  context 'with slots_offset' do
    let(:slots_offset) { "16:00" }

    it "returns doctors availabilities" do
      slots = slots(call)

      expect(call.size).to eq(4)
      expect(slots[0]).to include({:start=>"2023-11-27 16:00:00 UTC", :end=>"2023-11-27 17:00:00 UTC", :dow=>1})
      expect(slots[1]).to include({:start=>"2023-11-27 17:00:00 UTC", :end=>"2023-11-27 18:00:00 UTC", :dow=>1})

      expect(slots[2]).to include({:start=>"2023-11-28 16:00:00 UTC", :end=>"2023-11-28 17:00:00 UTC", :dow=>2})
      expect(slots[3]).to include({:start=>"2023-11-28 17:00:00 UTC", :end=>"2023-11-28 18:00:00 UTC", :dow=>2})
    end
  end

  context 'with appointments' do
    let!(:appointment_monday) { create(:appointment, doctor:, patient:, wday: monday_at.wday, start_at: monday_at, end_at: monday_at + 2.hours) }
    let!(:appointment_tuesday) { create(:appointment, doctor:, patient:, wday: tuesday_at.wday, start_at: tuesday_at, end_at: tuesday_at + 2.hours) }

    it "returns doctors availabilities" do
      slots = slots(call)

      expect(call.size).to eq(12)
      expect(slots[0]).to include({:start=>"2023-11-27 11:00:00 UTC", :end=>"2023-11-27 12:00:00 UTC", :dow=>1})
      expect(slots[1]).to include({:start=>"2023-11-27 12:00:00 UTC", :end=>"2023-11-27 13:00:00 UTC", :dow=>1})
      expect(slots[2]).to include({:start=>"2023-11-27 14:00:00 UTC", :end=>"2023-11-27 15:00:00 UTC", :dow=>1})
      expect(slots[3]).to include({:start=>"2023-11-27 15:00:00 UTC", :end=>"2023-11-27 16:00:00 UTC", :dow=>1})
      expect(slots[4]).to include({:start=>"2023-11-27 16:00:00 UTC", :end=>"2023-11-27 17:00:00 UTC", :dow=>1})
      expect(slots[5]).to include({:start=>"2023-11-27 17:00:00 UTC", :end=>"2023-11-27 18:00:00 UTC", :dow=>1})

      expect(slots[6]).to include({:start=>"2023-11-28 11:00:00 UTC", :end=>"2023-11-28 12:00:00 UTC", :dow=>2})
      expect(slots[7]).to include({:start=>"2023-11-28 12:00:00 UTC", :end=>"2023-11-28 13:00:00 UTC", :dow=>2})
      expect(slots[8]).to include({:start=>"2023-11-28 14:00:00 UTC", :end=>"2023-11-28 15:00:00 UTC", :dow=>2})
      expect(slots[9]).to include({:start=>"2023-11-28 15:00:00 UTC", :end=>"2023-11-28 16:00:00 UTC", :dow=>2})
      expect(slots[10]).to include({:start=>"2023-11-28 16:00:00 UTC", :end=>"2023-11-28 17:00:00 UTC", :dow=>2})
      expect(slots[11]).to include({:start=>"2023-11-28 17:00:00 UTC", :end=>"2023-11-28 18:00:00 UTC", :dow=>2})
    end
  end
end