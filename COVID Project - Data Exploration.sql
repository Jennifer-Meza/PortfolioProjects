/*
COVID Portfolio Project

Skills used: Joins, CTE's, Windows Functions, Aggregrate Functions, Converting Data Types, Creating Views
*/

-- Covid Death Table Information
SELECT * 
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Select data we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Deaths vs. Total Cases in: US and Peru
-- Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS USDeathPercentage
FROM CovidProject.coviddeaths
WHERE location LIKE '%states'
AND continent IS NOT NULL
ORDER BY location, date;

SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS PeruDeathPercentage
FROM CovidProject.coviddeaths
WHERE location = 'Peru'
AND continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Population in: US and Peru
-- Shows what percentage of population got COVID
SELECT location, date, total_cases, Population, (total_cases/population)*100 AS USPercentPopulationInfected
FROM CovidProject.coviddeaths
WHERE location LIKE '%states'
AND continent IS NOT NULL
ORDER BY location, date;

SELECT location, date, total_cases, Population, (total_cases/population)*100 AS PeruPercentPopulationInfected
FROM CovidProject.coviddeaths
WHERE location = 'Peru'
AND continent IS NOT NULL
ORDER BY location, date;

-- Looking at Countries in the Americas with Highest Infection Rate compared to Population 
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject.coviddeaths
WHERE continent LIKE '%america'
GROUP BY continent, location, population
ORDER BY continent, PercentPopulationInfected DESC;

-- Looking at Countries in the Americas with Highest Death Count per Population
SELECT continent, location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidProject.coviddeaths
WHERE continent LIKE '%america'
GROUP BY continent, location
ORDER BY continent, TotalDeathCount DESC;

-- Looking at Countries in the Americas with Total Death Count per Population 
SELECT continent, location, SUM(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidProject.coviddeaths
WHERE continent LIKE '%america'
GROUP BY continent, location
ORDER BY continent, TotalDeathCount DESC;

-- Breaking Things Down by Continent 
-- Showing continents with highest death count per population 
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS HighestDeathCount
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global Numbers
SELECT date, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases;


-- Covid Vaccination Table Information
SELECT *
FROM CovidProject.covidvaccinations
ORDER BY location, date;

-- Total Vaccinations vs Population in: US and Peru
-- Shows the percentage of Peru's population that got vaccinated
SELECT dea.location, dea.date, vac.total_vaccinations, dea.population, 
(vac.total_vaccinations/dea.population)*100 AS VaccinatedPercentage
FROM CovidProject.coviddeaths AS dea
JOIN CovidProject.covidvaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE vac.location = '%states';

SELECT dea.location, dea.date, vac.total_vaccinations, dea.population, 
(vac.total_vaccinations/dea.population)*100 AS VaccinatedPercentage
FROM CovidProject.coviddeaths AS dea
JOIN CovidProject.covidvaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE vac.location = 'Peru';

-- Total Population vs Vaccinations in the Americas
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 AS TotalPeopleVaccinated
FROM CovidProject.coviddeaths AS dea
JOIN CovidProject.covidvaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent LIKE '%america'
ORDER BY dea.location, dea.date;

-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidProject.coviddeaths AS dea
JOIN CovidProject.covidvaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent LIKE '%america'
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPerc
FROM PopvsVac;

-- Create View 
Create View PercentPopVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
as RollingPeopleVaccinated
FROM CovidProject.coviddeaths AS dea
JOIN CovidProject.covidvaccinations AS vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent LIKE '%america';