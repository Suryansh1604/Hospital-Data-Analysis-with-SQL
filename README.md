# 🏥 Hospital Performance Data Analytics Project

## Project Overview

This project involves a deep-dive analysis of hospital operational and patient data using SQL. The primary objective is to evaluate service efficiency, staff performance, and patient experience to identify critical areas for intervention and strategic investment. By answering key business questions related to patient refusals, resource allocation, and satisfaction consistency, the analysis provides a comprehensive framework for improving hospital management and patient care standards.

## Problem Statement

The hospital is facing challenges in key operational areas, including unacceptable patient refusal rates in certain services, mismatched bed capacity planning, and inconsistent patient satisfaction. The goal is to leverage data from weekly service logs, staff schedules, and patient records to diagnose the root causes of these inefficiencies and recommend data-driven solutions to enhance care quality and operational effectiveness.

## Dataset Information

The analysis utilizes a relational database named `hospital` with the following key tables:

- **services_weekly**: Contains weekly aggregate data for each service, including:
  - `service`: The hospital department (e.g., 'emergency', 'ICU', 'surgery').
  - `week`: The week number.
  - `patients_request`, `patients_admitted`, `patients_refused`: Patient flow metrics.
  - `available_beds`: Resource capacity.
  - `patient_satisfaction`, `staff_morale`: Key performance indicators (KPIs).
  - `event`: External factors like 'flu' or 'strike'.

- **staff_schedule**: Tracks staff attendance and roles across services:
  - `staff_name`, `service`, `week`, `role` (e.g., 'doctor', 'nurse').
  - `present`: A binary flag for staff attendance (1 for present, 0 for absent).

- **patients**: Individual patient records:
  - `arrival_date`, `departure_date`: Metrics for length of stay.
  - `satisfaction`, `age`: Patient demographic and experience data.

## Technical Skills and Tools

- **Database**: SQL (Advanced concepts: CTEs, Window Functions like `lag()`, `lead()`, `ntile()`, and conditional aggregation).

## Project Execution: Key Analytical Queries

### 1. Service Failure and Capacity Mismatch
**Goal**: Identify services failing patients and areas where resources (beds) are underutilized despite patient refusals.

- **Finding the Most Failing Service (Q1 A)**:  
  **Insight**: Emergency service has the highest patient refusal rate (over 50% of requests), indicating an unacceptable standard of care and critical undercapacity or processing bottlenecks.

- **Identifying Mismatched Capacity (Q1 B)**:  
  **Insight**: General Medicine is turning away the most patients while still having available beds, suggesting a problem with staffing or workflow rather than just physical bed capacity.

### 2. Patient Experience and Investment Strategy
**Goal**: Assess patient satisfaction consistency and determine where investment in additional beds or resources is most needed.

- **Service with Worst Experience vs. High Resources (Q2 A)**:  
  **Insight**: General Medicine and Surgery consume high resources (many available beds) but yield low average patient satisfaction, suggesting poor service quality is not due to lack of physical beds.

- **Where to Invest in Additional Beds (Q2 C)**:  
  **Insight**: General Medicine and ICU show a combination of high patient satisfaction and high patient refusals, suggesting that if more beds were available, the hospital could serve more patients without sacrificing quality.

### 3. Staffing and Morale Analysis
**Goal**: Evaluate staff-to-patient ratios, attendance, and morale to identify burnout risks and poor utilization.

- **Departments with Dangerously Low Staff-to-Patient Ratios (Q3 A)**:  
  **Insight**: Surgery and General Medicine consistently show the lowest staff-to-patient ratios, pointing to high workloads that increase the risk of errors and staff burnout.

- **Staff Absenteeism (Q3 B)**:  
  **Insight**: Emergency Doctors and General Medicine Doctors/Nurses have an attendance rate of less than 60%, signaling that these roles/departments are letting the hospital down with poor attendance.

- **Services at Risk of Staff Burnout (Q5 A)**:  
  **Insight**: General Medicine and Surgery are at the highest risk, primarily due to managing a high number of patients (totalpatients is high) while having a low average morale-per-patient score.

## Data Interpretation and Key Insights
