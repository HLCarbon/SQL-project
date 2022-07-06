SELECT *
FROM covid..covid

-- Everything seems to be in here.

-- Retrieve only some columns

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid..covid
ORDER BY location, date;

-- Look at total cases vs total deaths
-- If you contract covid, this shows the percentage of dying
SELECT location, date, total_cases,  total_deaths, ROUND((total_deaths/total_cases),4)*100 AS Death_percentage
FROM covid..covid
WHERE location = 'Portugal'
ORDER BY location, date;

-- Look at total cases vs population
SELECT location, date, total_cases,  population, ROUND((total_cases/population),4)*100 AS Cases_vs_population
FROM covid..covid
WHERE location = 'Portugal'
ORDER BY location, date;

-- 50% for Portugal, jesus.

--Highest infection rate
SELECT location, MAX(total_cases),  population, ROUND((MAX(total_cases)/population),4)*100 AS Infection_rate
FROM covid..covid
GROUP BY location, population
ORDER BY Infection_rate desc;

--Faeroe Islands won at 70.65 but Portugal has the 9th place.

--Highest death rate
-- We have to change the datatype to int or you will get the wrong number
-- We can see that the the continents are also in the location, so we have to remove it.
SELECT location, MAX(CAST(total_deaths AS INT)) AS MAX_DEATHS
FROM covid..covid
Where continent is not Null
GROUP BY location, population
ORDER BY MAX_DEATHS desc;

-- See by continent 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS MAX_DEATHS
FROM covid..covid
GROUP BY continent
ORDER BY MAX_DEATHS desc;
