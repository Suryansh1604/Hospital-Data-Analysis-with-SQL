# Hospital Data Analytics Project

## Project Overview
This project involves a deep-dive analysis of weekly hospital service data, patient records, and staff schedules to assess operational efficiency, identify failure points, and provide strategic recommendations for improving patient care, staff morale, and resource allocation. The analysis focuses on key areas like patient refusal rates, bed capacity planning, patient satisfaction, staff-to-patient ratios, and the impact of external events (like flu or strikes).

## Problem Statement
The hospital management needs a data-driven assessment to understand where services are failing patients, where resources are being misused (staff and beds), and what factors are negatively impacting patient satisfaction and staff performance. Specifically, there is a need to identify the services most at risk of staff burnout and the departments requiring emergency intervention to maintain care standards.

## Dataset Information
The analysis utilizes a relational database (hospital) with tables such as services_weekly, patients, and staff_schedule. These tables contain weekly operational and performance metrics.

Key fields in the dataset include:

**services_weekly**: Service type (e.g., Emergency, ICU), patients requested/refused/admitted, available beds, patient satisfaction, staff morale, and event markers (flu, strike).

**staff_schedule**: Staff name, service, role (Doctor, Nurse, etc.), and attendance status (present/absent).

**patients**: Patient demographics (age), service, arrival/departure dates, and final satisfaction score.

## Technical Skills and Tools
**Database**: SQL

## Project Execution

### Phase 1 - 4: Data Preparation & Engineering
The initial phases involved structuring the data for analysis, which included joining relevant tables and calculating critical metrics directly within the queries.

**Action**:

- Calculated key operational metrics such as Patient Refusal Rate and Satisfaction per Bed.

- Developed metrics for capacity analysis like the Refusal-to-Available-Bed Ratio.

- Used Window Functions (NTILE, LAG, LEAD, ROW_NUMBER) to determine staff-to-patient ratio rankings and identify staff absence streaks (abandoned posts).

**Outcome**: A structured query-set that transformed raw operational data into actionable performance and risk indicators.

### Phase 5: Data Analysis
**Task**: Perform an in-depth analysis using SQL queries to diagnose operational inefficiencies and performance risks.

**Action**:

1. **Identified Service Failure Rate**: Determined which service has the highest patient refusal rate.
```sql
SELECT
    service,
    (SUM(patients_refused) / SUM(patients_request) * 100) AS patient_refusal_rate
FROM
    services_weekly
GROUP BY
    service
ORDER BY
    patient_refusal_rate DESC;
```

2. **Analyzed Mismatched Capacity**: Pinpointed services refusing patients despite having available beds.
```sql
SELECT
    service,
    SUM(available_beds) - SUM(patients_admitted) AS bed_left,
    SUM(patients_refused) AS patient_refused
FROM
    services_weekly
GROUP BY
    service
HAVING
    bed_left > 0 AND patient_refused > 0
ORDER BY
    bed_left DESC;
```

3. **Assessed Staff Burnout Risk**: Ranked services by patient load and morale.
```sql
SELECT
    service,
    SUM(patients_admitted) AS totalpatients,
    AVG(staff_morale) / SUM(patients_admitted) AS morale_per_patient
FROM
    services_weekly
GROUP BY
    service
ORDER BY totalpatients DESC, morale_per_patient ASC;
```

**Outcome**: Identified critical issues in resource management, staff deployment, and patient care quality, leading to specific, targeted recommendations.

## Data Interpretation and Key Insights
The analysis provides a clear, quantitative basis for making operational and strategic changes, focusing on patient experience and resource optimization.

### Key Insights and Recommendations:

1. **Critical Service Failure**: The Emergency service has an unacceptably high patient refusal rate (over 50%), requiring an immediate review of its triage and admission policies. Care standards were violated in multiple weeks with refusal rates between 65% and 80%.

2. **Mismatched Capacity**: General Medicine is turning away the most patients while beds sit empty, suggesting a severe staffing or internal resource allocation bottleneck, not a physical bed shortage. More staff should be allocated.

3. **Staffing & Attendance**: Doctors in Emergency and General Medicine, and Nurses in General Medicine have the lowest attendance (less than 60%). Staff strikes cause more cumulative damage than flu outbreaks.

4. **Vulnerable Groups**: Old and Adult age groups have the lowest patient satisfaction, indicating a need for targeted improvements in care quality or communication for these demographics.

5. **Resource Investment**: ICU and General Medicine should be prioritized for additional bed investment due to high patient satisfaction despite high refusal rates.
