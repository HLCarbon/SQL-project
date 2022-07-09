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

-- Showing the continents with the highest death per population

-- See globally the death percentage
SELECT date, SUM(total_cases) as total_cases, SUM(CAST(total_deaths AS INT)) total_deaths, ROUND(SUM(CAST(total_deaths AS INT))/SUM(total_cases)*100,2) as death_percentage
FROM covid..covid
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- Total population vs total vaccinations

Select date, SUM(population) as population, SUM(CAST(people_fully_vaccinated AS FLOAT)) as people_fully_vaccinated,
SUM(CAST(people_fully_vaccinated AS FLOAT))/SUM(population) as vaccination_percentage
FROM covid..covid
WHERE continent is not null
GROUP BY date

-- Rolling count of vaccinations
SELECT location, continent, date, population, CAST(new_vaccinations AS bigint) as new_vaccinations, 
SUM(CAST(new_vaccinations AS INT)) OVER(
PARTITION BY location
ORDER BY location, date) as rolling_vacc
FROM covid..covid
WHERE continent is not null;


--using common table expression (CTE)

WITH populationvsvacc (location, continent, date, population,new_vaccinations, rolling_vacc)
AS
(
SELECT location, continent, date, population, CAST(new_vaccinations AS bigint) as new_vaccinations, 
SUM(CAST(new_vaccinations AS INT)) OVER(
PARTITION BY location
ORDER BY location, date) as rolling_vacc
FROM covid..covid
WHERE continent is not null
)

SELECT *, ROUND(rolling_vacc/population*100,2)
FROM populationvsvacc



--Create temporary table

DROP TABLE IF EXISTS #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population NUMERIC,
new_vaccinations NUMERIC,
rolling_vacc NUMERIC
)


INSERT into #PercentPopulationvaccinated
SELECT location, continent, date, population, CAST(new_vaccinations AS bigint) as new_vaccinations, 
SUM(CAST(new_vaccinations AS bigint)) OVER(
PARTITION BY location
ORDER BY location, date) as rolling_vacc
FROM covid..covid
WHERE continent is not null

SELECT *, ROUND(rolling_vacc/population*100,2)
FROM #PercentPopulationvaccinated


-- Create view to store data

CREATE VIEW population_vaccinated_view AS
SELECT location, continent, date, population,
CAST(new_vaccinations AS bigint) as new_vaccinations, 
SUM(CAST(new_vaccinations AS bigint)) OVER(
PARTITION BY location
ORDER BY location, date) as rolling_vacc
FROM covid..covid
WHERE continent is not null

-- Change date format to date instead of nvchar(255)

ALTER TABLE covid..covid
ALTER COLUMN date date


-- Populate icu_patients NULL values to contain 0
SELECT*
FROM covid..covid

UPDATE covid
SET icu_patients = 0
WHERE icu_patients is null


SELECT*
FROM covid..covid