
class Doctors::AvailabilityQuery
  # param availability_range:string generates slots for day | week | month | year;
  # param slots_range:string filters slots for all | asap | tomorrow;
  # param slots_step:string represents slots bounding 15 minutes | 30 minutes | 1 hour
  # param slots_offset:string allows to skip N first slots 11:00 AM
  # param slots_limit:string allows to limit N last slots 04:00 PM
  def initialize(filters = {})
    @filters = filters
    @doctor = filters[:doctor]
  end
  attr_reader :filters, :doctor

  def call
    scope = base_scope
    scope = scope.joins(generate_series_sql)
    scope = scope.joins(appointments_sql)
    scope = scope.where(doctor_id: doctor.id)
    scope = scope.where(appointments: { id: nil })
    scope = scope.where(where_sql)
    scope = scope.group(group_by_sql)
    scope = scope.select(select_sql)

    scope
  end

  private

  def select_sql
    if filters[:slots_range] != 'asap'
      <<~SQL
        series_hour as slot_start_at, 
        series_hour + #{slots_interval_sql} as slot_end_at,
        extract(dow from series_hour)::integer as slot_dow
    SQL
    else
      <<~SQL
        min(series_hour) as slot_start_at, 
        min(series_hour) + #{slots_interval_sql} as slot_end_at,
        extract(dow from min(series_hour))::integer as slot_dow
    SQL
    end
  end

  def group_by_sql
    return '' unless filters[:slots_range] == 'asap'

    'extract(dow from series_hour)'
  end

  def where_sql
    sql = ''

    sql += " working_hours.wday = #{DateTime.current.wday + 1}" if filters[:slots_range] == 'tomorrow'
    sql += " series_hour >= date_trunc('day', series_hour) + '#{Time.zone.parse(filters[:slots_offset])}'::time" if filters[:slots_offset]
    sql += " series_hour < date_trunc('day', series_hour) + '#{Time.zone.parse(filters[:slots_limit])}'::time" if filters[:slots_limit]

    sql
  end

  # Create schedule for 'current date' based on view date
  # As we don't generate working hours for future dates we need to simulate this
  def generate_series_sql
    <<~SQL
        INNER JOIN generate_series('#{availability_range.begin}'::timestamp, '#{availability_range.end}'::timestamp, #{slots_interval_sql}) series_hour
        ON  working_hours.wday = extract(dow from series_hour) AND
            series_hour >= (date_trunc('day', series_hour) + CAST(working_hours.start_at AS TIME)) AND
            series_hour < (date_trunc('day', series_hour) + CAST(working_hours.end_at AS TIME))
    SQL
  end

  # Check which slots are booked
  def appointments_sql
    <<~SQL
        LEFT JOIN appointments ON appointments.doctor_id = working_hours.doctor_id AND appointments.wday = extract(dow from series_hour) AND (
            (appointments.start_at >= series_hour AND appointments.start_at < (series_hour + #{slots_interval_sql}))
        OR
            (appointments.end_at > series_hour AND appointments.end_at <= (series_hour + #{slots_interval_sql}))
        )
    SQL
  end

  def slots_interval_sql
    "'#{slots_step}'::interval"
  end

  def slots_step
    case filters[:slots_step]
    when '1/4' then '15 minutes'
    when '1/2' then '30 minutes'
    when '1' then '1 hour'
    else
      ArgumentError('An slots_step is omitted')
    end
  end

  def availability_range
    case filters[:availability_range]
    when 'day' then DateTime.current.all_day
    when 'week' then DateTime.current.all_week
    when 'month' then DateTime.current.all_month
    when 'year' then DateTime.current.all_year
    else
      ArgumentError('An availability_range is omitted')
    end
  end

  def base_scope
    WorkingHour.all
  end
end
