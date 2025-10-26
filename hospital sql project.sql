use hospital;
show tables;

-- 1 A Which hospital service is failing patients most often, and when are our refusal rates unacceptable?
select
    service,
    (sum(patients_refused) / sum(patients_request) * 100) as patient_refusal_rate
from
    services_weekly
group by
    service
order by
    patient_refusal_rate desc;
    
-- emergency has the high refusal rate as it refuses more than 50 percent of patients which is unacceptable.





-- 1 B Where are we turning away patients while beds sit empty? Identify mismatched capacity planning.
-- Find out service where patients are refused even if beds are availaible.
select
    service,
    sum(available_beds) - sum(patients_admitted) as bed_left,
    sum(patients_refused) as patient_refused,
    sum(patients_refused)/(sum(available_beds) - sum(patients_admitted)) * 100 as refuse_to_availaible_bed_ration
from
    services_weekly
group by
    service
having
    sum(available_beds) - sum(patients_admitted) > 0 and
    sum(patients_refused) > 0
order by
	refuse_to_availaible_bed_ration desc;

-- The most patient are refused in general_medicine which can lead to losses so more staff should be alloted to general_medicine






-- 1 C When did patient satisfaction collapse by more than 20%?
with pivotweek as (
select
	service,
    sum(case when week = 1 then patient_satisfaction end) as week1,
    sum(case when week = 2 then patient_satisfaction end) as week2,
    sum(case when week = 3 then patient_satisfaction end) as week3
from
	services_weekly
group by
	service
)
select
	service,
    case
		when ((week1 - week1)/week1) * 100 and ((week1 - week1)/week1) * 100 < 20 then ((week1 - week1)/week1) * 100 end as week1change,
	case
		when ((week2 - week1)/week1) * 100 and ((week2 - week1)/week1) * 100 < 20 then ((week2 - week1)/week1) * 100 end as week2change,
	case
		when ((week3 - week2)/week2) * 100 and ((week3 - week2)/week2) * 100 < 20 then ((week3 - week2)/week2) * 100 end as week3change
from
	pivotweek;    
-- Mostly in all services and satisfaction is collapsed in less than 20 percent from week2 to week3
-- leaving week2 to week3 in general_medicine





-- 1 D Do flu outbreaks or staff strikes cause more damage?
with grpsatisfaction as (
select
    event,
    avg(staff_morale) as staff_morale,
    avg(patient_satisfaction) as patient_satisfaction
from
    services_weekly
where
    event in ('flu', 'strike')
group by
    event
)
select
	*
from
	grpsatisfaction
order by
    staff_morale + patient_satisfaction;
    
-- strike has done more damage as it reduced the morale of staff significantly although patient are satisfied





-- 1 E Are we sacrificing patient satisfaction by overloading beds?
with grpbed as (
    select
        case
            when available_beds = patients_admitted then "Full"
            else "Remaining"
        end as bed_status,
        ntile(2) over (order by patient_satisfaction desc) as rnk
    from
        services_weekly
)

select
    bed_status,
    count(case when rnk = 1 then rnk end) as "High_Satisfaction_Count",
    count(case when rnk = 2 then rnk end) as "Low_Satisfaction_Count",
    case 
		when  count(case when rnk = 1 then rnk end) > count(case when rnk = 2 then rnk end) then "High_Satisfaction_Count"
        else "Low_Satisfaction_Count"
	end as highest_scorer
from
    grpbed
group by
    bed_status;
    
-- we can see the pattern that as long as the bed are filling the people with high 
-- satisfaction are decreasing so we can say that if bed will overpopulate with patients
-- then satisfaction will decrease







-- 2 A Which service generates worst patient experience despite high resources?
select
    service,
    avg(patient_satisfaction) as satisfaction,
    sum(available_beds) as available_beds
from
    services_weekly
group by
    service
order by
    3 desc, 2 asc;
    
-- general medicine and surgery are the services consuming more resources and giving less satisfaction.





-- 2 B How much revenue are we losing from patient refusals?
-- Don't know






-- 2 C Where should we invest in additional beds?
with refused_satisfied as (
select
  service,
  sum(patient_satisfaction) as patient_satisfaction,
  sum(patients_refused) as patient_refused  
from
  services_weekly
group by
  service
)
select
	*
from
	refused_satisfied
order by
	patient_satisfaction desc,
    patient_refused desc;
    
-- In general_medicing and ICU we can invest on more beds becouse here bed are less so we refused more patient
-- But still we can see the patient are satisfied






-- 2 D Which services deliver best satisfaction per bed?

select
	service,
    (sum(patient_satisfaction)/sum(available_beds)) * 100 as satisfaction_per_bed_in_percentage
from
	services_weekly
group by service
order by satisfaction_per_bed_in_percentage desc;

-- ICU and Emergency has the better satisfaction per bed in percentage as compared to other services









-- 3 A Which departments have dangerously low staff-to-patient ratios? 
With weekratio as (
  select
    sw.week as week,
    sw.service as service,
    count(distinct ss.staff_name)/sum(sw.patients_admitted) * 100 as ratio
  from
    services_weekly sw
    left join staff_schedule ss on ss.service = sw.service
where present = 1
  group by
    sw.week,
    sw.service
),
ratiorank as (
  select
    *,
    row_number() over (partition by week order by
      ratio asc) as rnk
  from
    weekratio
)
select
  week,
  sum(case when service = 'emergency' then rnk end) as emergency,
  sum(case when service = 'surgery' then rnk end) as surgery,
  sum(case when service = 'ICU' then rnk end) as ICU,
  sum(case when service = 'general_medicine' then rnk end) as general_medicine
from
	ratiorank
group by
	week;
    
-- in week 1 surgery and general_medicine have the lowest ratio of staff_to_patient therefore surgery and
-- general_medicine get the first and second rank rest rank are given below
-- Similarly all the low rank department are given in table below



    
-- 3 B Are doctors, nurses, or assistants letting us down with poor attendance?
WITH present_absent AS (
    SELECT
        service,
        role,
        COUNT(CASE WHEN present = 1 THEN 1 END) AS present,
        COUNT(CASE WHEN present = 0 THEN 1 END) AS absent
    FROM
        staff_schedule
    GROUP BY
        service,
        role
)
SELECT
    *,
    ((present/(present+absent)) * 100) as present_in_percentage,
    CASE
        WHEN present > absent and ((present/(present+absent)) * 100) > 60 THEN 'Present'
        ELSE 'Absent'
    END AS high_score
FROM
    present_absent
order by high_score asc;

-- emergency doctors, surgery nursing_assistant, general_medicine doctor and nurse are letting us down
-- becouse then have less than 60 percent attendance so they need to take less leave.






-- 3 C Where do we have staff showing up but not enough patients?
SELECT
    sw.service,
    COUNT(DISTINCT ss.staff_name) AS staff_count,
    SUM(sw.patients_admitted) AS patient_count
FROM
    services_weekly sw
LEFT JOIN
    staff_schedule ss ON ss.service = sw.service
GROUP BY
    sw.service
ORDER BY
    staff_count DESC,
    patient_count ASC;
    
-- emergency and ICU have more staff but less patient are admitted in this services.








-- 3 D Which team members have abandoned their posts?
-- week staff_name streak streakid
-- week staff_name streak
-- week staff_name lagdiff = 1 or leaddiff = 1 of week present = 0

with streak as (
select
	week,
    staff_name,
    service,
    week - lag(week) over (partition by staff_name order by week) as lagdiff,
    lead(week) over (partition by staff_name order by week) - week as leaddiff
from
	staff_schedule
where present = 0
), streakname as (
select
	service,
    staff_name,
    leaddiff,
    lagdiff,
    count(week) as streak
from
	streak
where lagdiff = 1 or leaddiff = 1
group by
	service,
    staff_name,
    lagdiff,
    leaddiff
)
select
	staff_name,
    service,
    max(streak) as absent_streak
from
	streakname
where 
	streak > 1
group by staff_name,service
order by 3 desc;

-- Angela Lopez in general_medicine
-- alison hill and angie henderson in emergency has the highest absent streak so they might have
-- abondoned their post

-- 3 A Are we keeping patients too long without improving satisfaction?
select
    datediff(departure_date, arrival_date) as no_of_days_spent,
    avg(satisfaction) as satisfaction,
    case 
		when avg(satisfaction) > 79.61102143 then "High"
        else "Low"
	end as valuestatus
from
    patients
group by
    datediff(departure_date, arrival_date)
order by
    no_of_days_spent desc;

-- No becouse in this table more time in hospital is giving high satisfaction as compared to low time 
-- so if we are keeping patient for long time then on average satisfaction is increase 
-- we have rare case of reduced patient satisfaction like patient who spent 13 days  in hospital
-- has low patient satisfaction.




-- 3 B Which service delivers most consistent patient experience?
 
with avg_satisfaction as (
  select
    service,
    week,
    avg(patient_satisfaction) as satisfaction
  from
    services_weekly
  group by
    service,
    week
)
select
  service,
  stddev(satisfaction) as consistent_satisfaction_value
from
  avg_satisfaction
group by
  service
order by 2 desc;

-- surgery and emergency service are providing consistent satisfaction to patient across the week.





-- 3 D Where do we have staff showing up but not enough patients, wasting salary costs?

-- service count_staff asc count_patient desc

select
	sw.service,
    sum(patients_admitted) as totalpatients,
    count(staff_name) as totalstaff
from
	services_weekly sw
    left join staff_schedule ss on ss.service = sw.service
group by
	service
order by
	2 desc, 3 asc;
    
    
    
-- general_medicine and emergency are the service in which there are more patient but low staff present rate






-- 4 A Are we keeping patients too long without improving satisfaction?

select 
	datediff(departure_date,arrival_date) as time_spent,
    avg(satisfaction) as satisfaction
from
	patients
group by
	time_spent
order by time_spent desc;

-- No satisfaction is increasing as consumer are spending more time in hospital and there are a rare cases 
-- where satisfaction is low when the consumer spent more time




-- 4 B Which service delivers most consistent patient experience?

-- week service avg(satisfaction)
-- service stddev(satisfaction)

with grpsatisfaction as (
select
	week,
    service,
    avg(patient_satisfaction) as satisfaction
from
	services_weekly
group by
	week,
    service
)
select
	service,
    stddev(satisfaction) as satisfaction
from
	grpsatisfaction
group by service
order by 2 desc;

-- surgery and emergency are the services that are providing consistant satisfaction.







-- 4 C Are we failing specific age groups?

-- 0 - 4 Baby
-- 5 - 17 Children
-- 18 - 25 Youth
-- 25 - 50 Adult
-- Above 50 Old

select
	case
		when age between 0 and 4 then "Baby"
        when age between 5 and 17 then "Children"
        when age between 18 and 25 then "Youth"
        when age between 26 and 50 then "Adult"
        else "Old"
    end as age_group,
    avg(satisfaction) as satisfaction
from
	patients
group by
	age_group
order by satisfaction asc;

-- We are failing in old and adult age_group becouse they have the lowest satisfaction.







-- 4 D Does keeping ICU patients longer lead to better outcomes?

select 
	service,
	datediff(departure_date,arrival_date) as time_spent,
    avg(satisfaction) as satisfaction
from
	patients
where
	service = 'ICU'
group by
	time_spent,
    service
order by time_spent desc;

-- Yes keeping ICU patient longer is increasing the patient satisfaction as more time spent is leading to 80 to 84 percent of satisfaction.





-- 5 A Which services are at risk of staff burnout?

-- services highpatient_admitted desc declining staff_morale asc

select
	service,
    sum(patients_admitted) as totalpatients,
    avg(staff_morale)/sum(patients_admitted) as moraleperpatient
from
	services_weekly
group by
	service
order by 2 desc, 3 asc;

-- services like general_medicine and surgery are at risk of staff burnout becouse of more patients coming
-- in hospital for their service.

			



-- 5 B When did we violate care standards?

select
	week,
    (sum(patients_refused)/sum(patients_request) * 100) as patient_refused_percentage
from
	services_weekly
group by
	week
having (sum(patients_refused)/sum(patients_request) * 100) > 50
order by 2 desc;

-- in week 5 12 2 8 and 18 we have violated care standards at extreme level becouse patient refuse
-- lies between 65 to 80 %





-- 5 C Which departments need emergency intervention?

-- department DangerZone
-- service staff_more patient_satisfaction patients_refused

with morale_satisfaction_refused as (
select
	service,
    sum(staff_morale) as staffmorale,
    sum(patient_satisfaction) as patientsatisfaction,
    sum(patients_refused) as patientrefused
from
	services_weekly
group by
	service
),rankperformance as (
select
	service,
    staffmorale,
    ntile(2) over (order by staffmorale desc) as moralerank,
    patientsatisfaction,
    ntile(2) over (order by patientsatisfaction desc) as satisfactionrank,
    patientrefused,
    ntile(2) over (order by patientrefused asc) as patientrefusedrank
from
	morale_satisfaction_refused
)
select
	service,
    case
		when moralerank + satisfactionrank + patientrefusedrank in (3,4) then "Good"
        else "Danger"
	end as flag,
    moralerank,
    satisfactionrank,
    patientrefusedrank
from 
	rankperformance;

-- surgery is in danger due to low morale and low satisfaction.
-- emergency is in danger due to due to low satisfaction and more patient refused.

-- surgery and emergency need emergency intervention.





-- 4 D Are we prepared for next flu season?
-- event week satisfaction morale refused 
-- part2 - dividing satisfaction morale and cancelled column values into high and low
-- part3 - comparing flu with other event

with cteevent as (
select distinct event as event from services_weekly) 
select concat("sum(case when event = '",event,"' then patient_satisfaction end) as ",event,",") from cteevent;
    

with grpsatisfaction as (    
select
	event,
    week,
    sum(patient_satisfaction)/ sum(patients_admitted) as satisfaction_per_patient
from
	services_weekly
where
	event = 'flu'
group by
	event, week
)
select
	*,
    ntile(3) over (order by satisfaction_per_patient desc) as rnk
from
	grpsatisfaction
order by week asc;
-- we are not prepared for the flu season becouse week 1 week3 and week4 has extremely high satisfaction
-- but as the week is increasing satisfaction is becoming lower and more extreme fluctuation is present in
-- the coming weeks.


