-- Show unique birth years from patients and order them by ascending.
SELECT DISTINCT YEAR(birth_date) AS birth_year FROM patients
ORDER BY birth_date ASC;

-- Show unique first names from the patients table which only occurs once in the list.
-- For example, if two or more people are named 'John' in the first_name column then don't include their name in the output list. If only 1 person is named 'Leo' then include them in the output.
SELECT first_name FROM patients
group by first_name
HAVING COUNT(first_name) = 1;

-- Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
SELECT patient_id, first_name FROM patients
WHERE first_name LIKE 'S%' AND first_name LIKE '%s' AND LENGTH(first_name) >= 6;

-- Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
SELECT patients.patient_id, patients.first_name, patients.last_name
FROM patients JOIN admissions
ON patients.patient_id = admissions.patient_id
WHERE admissions.diagnosis LIKE 'Dementia';

-- Display every patient's first_name.
-- Order the list by the length of each name and then by alphabetically.
SELECT first_name FROM patients
ORDER BY LENGTH(first_name), first_name;

-- Show the total amount of male patients and the total amount of female patients in the patients table.
-- Display the two results in the same row.
SELECT
(SELECT COUNT(gender) FROM patients WHERE gender LIKE 'M') AS male_count,
(SELECT COUNT(gender) FROM patients WHERE gender LIKE 'F') AS female_count;

-- Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.
SELECT first_name, last_name, allergies FROM patients
WHERE allergies IN ('Penicillin', 'Morphine')
ORDER BY allergies ASC, first_name, last_name;

-- Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
SELECT patient_id, diagnosis FROM admissions
GROUP BY diagnosis, patient_id
HAVING COUNT(*) > 1;

-- Show the city and the total number of patients in the city.
-- Order from most to least patients and then by city name ascending.
SELECT city, COUNT(patient_id) AS num_patients
FROM patients
GROUP BY city
ORDER BY num_patients DESC, city ASC;

-- Show first name, last name and role of every person that is either patient or doctor.
-- The roles are either "Patient" or "Doctor"
SELECT first_name, last_name, 'Patient' AS role FROM patients
UNION ALL
SELECT first_name, last_name, 'Doctor' AS role FROM doctors;
