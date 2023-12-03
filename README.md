# API contract

###### Endpoint to view a doctors availability
    Context: Used by doctor | nurse to see their schedules

###### Endpoint to find a doctors working hours
    Context: Used by patient to search most suitable slot

###### Endpoint to book a doctors open slot
    Context: Used by patient to book slot

###### Endpoint to update a doctors open slot
    Context: Used by patient to update slot

###### Endpoint to delete a doctors open slot
    Context: Used by patient to delete slot


# DB structure

```
entity Doctor
    name: String => Doctors Name

    has_many :appointments
    has_many :patients through: :appointments
    
    has_many :working_hours
end

entity Patient
    name: String => Patients Name
    
    has_many :appointments
end

entity WorkingHours
    start_at:   DateTime => Working start date
    end_at:     DateTime => Working end date
    wday:       Number   => Day of the week
    
    belongs_to :doctor
end

entity Appointment
    disease:    String => Appointments description
    start_at:   DateTime => Appointments start date
    end_at:     DateTime => Appointments end date
    wday:       Number   => Day of the week

    belongs_to :patient
    belongs_to :doctor
end
```

#### Working Hours
###### Represents doctors slot
    It is created for whole week by each day it contains start & stop dates.
    Like: M[09AM - 12AM] M[1PM - 6PM] T[11AM - 12AM] T[2PM - 4PM]

    I don't like idea to generate working hours for future days, 
    because it has tons of IO + we need to update records if schedule changed

    I use generate_series to create slots for day | week | month | year;
    You might use offset | limit to filter your preferred slots;
    You might use asap filter to search quickest open slot;
    You might adjust slots length;

    You might use materialized view to improve performance(update them when schedule changed)


#### Appointment
###### Represents appointments when doctor & patient discuss treatment

#### Doctor
###### Represents doctors who is participating in appointment

#### Patient
###### Represents patients who is participating in appointment


## Improvements
- add pundit
- add dry-schema, dry-validation
- add rubocop
- use arel to simplify Doctors::Availability
- add authn / authz
- add rescue_from
