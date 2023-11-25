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
    has_many :appointments
    has_many :patients through: :appointments
    
    has_many :working_houres
end

entity Patient
    has_many :appointments
end

entity WorkingHours
    belongs_to :doctor
end

entity Appointment
    belongs_to :patient
    belongs_to :doctor
end
```

#### Working Hours
###### Represents doctors slot
    It is created for whole week by each day it contains start & stop dates.
    Like: M[09AM - 12AM] M[1PM - 6PM] T[11AM - 12AM] T[2PM - 4PM]

#### Appointment
###### Represents appointments when doctor & patient discuss treatment

#### Doctor
###### Represents doctors who is participating in appointment

#### Patient
###### Represents patients who is participating in appointment
