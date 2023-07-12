CREATE TABLE gun_violence(
incident_id int,
incident_date date,
city varchar(50),
address varchar(255),
victims_killed int,
victims_injured int,
suspects_killed int,
suspects_injured int,
suspects_arrested int);

CREATE TABLE counties(
city varchar(50),
county varchar(50));

CREATE TABLE population(
county varchar(50),
population_2022 int);

COPY gun_violence
FROM 'C:\Users\Public\Michigan GVA.csv'
With(Format CSV, HEADER);

COPY counties
FROM 'C:\Users\Public\Michigan Cities and Counties.csv'
With(Format CSV, HEADER);

COPY population
FROM 'C:\Users\Public\Michigan County Populations 2022.csv'
With(Format CSV, HEADER);

SELECT * FROM gun_violence;
SELECT * FROM counties;
SELECT * FROM population;

SELECT *, EXTRACT(YEAR FROM(incident_date)) AS year
FROM gun_violence;

ALTER TABLE gun_violence ADD COLUMN year int;

UPDATE gun_violence
SET year = EXTRACT(YEAR FROM(incident_date));

SELECT incident_id, incident_date, address, gun.city, co.county, population_2022, 
victims_killed, victims_injured, suspects_killed, suspects_injured, suspects_arrested
FROM gun_violence gun
LEFT JOIN counties co ON gun.city = co.city
LEFT JOIN population pop ON co.county = pop.county
ORDER BY incident_date;

--Total incidents vs Total Deaths in 2022
SELECT 
 COUNT(incident_id) AS incident_count,
 (SUM(victims_killed) + SUM(suspects_killed)) AS total_deaths,
 (SUM(CAST(victims_killed AS decimal)) + SUM(suspects_killed))/COUNT(incident_id) AS deaths_per_incident
FROM gun_violence
WHERE year = 2022;

--Total incidents vs injuries and deaths in 2022
SELECT
COUNT(incident_id) 
  AS incident_count,
(SUM(victims_killed) + SUM(suspects_killed) + SUM(victims_injured) + SUM(suspects_injured)) 
  AS total_injuries_and_deaths,
  (SUM(CAST(victims_killed AS decimal)) + SUM(suspects_killed) + SUM(victims_injured) + 
SUM(suspects_injured))/COUNT(incident_id) 
  AS injuries_and_deaths_per_incident
FROM gun_violence
WHERE year = 2022;

-- Total incidents by county population in 2022
SELECT co.county, COUNT(gun.incident_id) AS incidents, population_2022, 
 round(COUNT(gun.incident_id)/CAST(population_2022 AS decimal)*100,2) AS percent_population
FROM gun_violence gun
LEFT JOIN counties co ON gun.city = co.city
LEFT JOIN population pop ON co.county = pop.county
WHERE year = 2022
GROUP BY co.county, population_2022
ORDER BY percent_population DESC;

--Total gun deaths by county population in 2022
SELECT co.county, population_2022,
(victims_killed + suspects_killed) AS total_deaths,
round((victims_killed + suspects_killed)/CAST(population_2022 AS decimal)*100,2)
AS percent_deaths
FROM gun_violence gun
LEFT JOIN counties co ON gun.city = co.city
LEFT JOIN population pop ON co.county = pop.county
WHERE year = 2022
GROUP BY co.county, victims_killed, suspects_killed, population_2022
ORDER BY percent_deaths DESC;

--Total gun deaths by county in 2022
SELECT co.county, population_2022, COUNT(incident_id) AS county_shootings, 
SUM(victims_killed + suspects_killed) AS county_gun_deaths
FROM gun_violence gun
LEFT JOIN counties co ON gun.city = co.city
LEFT JOIN population pop ON co.county = pop.county
WHERE year = 2022 
GROUP BY co.county, population_2022
ORDER BY county_gun_deaths DESC

--Total gun deaths by city in 2022
SELECT gun.city, co.county, COUNT(incident_id) AS city_shootings, 
SUM(victims_killed + suspects_killed) AS city_gun_deaths
FROM gun_violence gun
LEFT JOIN counties co ON gun.city = co.city
WHERE year = 2022 
GROUP BY gun.city, co.county
ORDER BY city_gun_deaths DESC;

