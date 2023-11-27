
class Doctors::Availability
  # param availability_range:string generates slots for day | week | month | year;
  # param slots_range:string filters slots for all | asap | tomorrow;
  # param slots_step:string represents slots bounding 15 minutes | 30 minutes | 1 hour
  # param slots_offset:string allows to skip N first slots 11:00 AM
  # param slots_limit:string allows to limit N last slots 04:00 PM
  def initialize(filters = {})
    @filters = filters
  end
  attr_reader :filters
  delegate :doctor, to: :filters

  def call
    scope = base_scope
    scope = join_series_hours(scope)
    scope = scope.where(where_sql)
    scope = scope.group(group_by_sql)
    scope = scope.select(select_sql)

    scope
  end

  private

  def select_sql
    if filters[:slots_range] == 'asap'
      sql = 'min(series_hour) as slot'
    else
      sql = 'series_hour as slot'
    end

    sql
  end

  def group_by_sql
    sql = ''

    sql += 'extract(dow from series_hour)' if filters[:slots_range] == 'asap'

    sql
  end

  def where_sql
    sql = ''

    sql += " working_hours.wday = #{DateTime.current.wday + 1}" if filters[:slots_range] == 'tomorrow'
    sql += " series_hour >= date_trunc('day', series_hour) + '#{Time.zone.parse(filters[:slots_offset])}'::time" if filters[:slots_offset]
    sql += " series_hour < date_trunc('day', series_hour) + '#{Time.zone.parse(filters[:slots_limit])}'::time" if filters[:slots_limit]

    sql
  end

  def join_series_hours(scope)
    scope.joins(generate_series_sql)
  end

  def generate_series_sql
    <<~SQL
        INNER JOIN
        generate_series('#{availability_range.begin}'::timestamp, '#{availability_range.end}'::timestamp, '#{slots_step}'::interval) series_hour
        ON  working_hours.wday = extract(dow from series_hour) AND
            series_hour >= (date_trunc('day', series_hour) + CAST(working_hours.start_at AS TIME)) AND
            series_hour < (date_trunc('day', series_hour) + CAST(working_hours.end_at AS TIME))
    SQL
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
