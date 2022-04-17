/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * 
from PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total cases vs total deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage, new_cases
FROM PortfolioProject..CovidDeaths
WHERE location='Bangladesh'
ORDER BY 1,2

--Looking at total cases vs population 
-- What percentage of population got Covid?

SELECT location, date, population, total_cases, (total_cases/population)*100 InfectedPercentagepopulation
FROM PortfolioProject..CovidDeaths
WHERE location='Bangladesh'
ORDER BY 1,2

-- Countries with highest infected rate compared to population

SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population)*100 InfectedPercentagepopulation
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
--HAVING location='Bangladesh'
ORDER BY InfectedPercentagepopulation desc


-- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int))TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
--HAVING location='Bangladesh'
ORDER BY TotalDeathCount desc


--DEATH COUNT IN CONTINETS

-- This is not correct though -_-


--SELECT continent, MAX(cast(total_deaths as int))TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount desc


--GLOBAL COUNTS EVERYDAY 

SELECT date, sum(new_cases) totalcases, SUM(cast(new_deaths as int)) totaldeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL COUNTS TOTAL

SELECT sum(new_cases) totalcases, SUM(cast(new_deaths as int)) totaldeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Join both tables


SELECT * 
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date


--TOTAL POPULATION VS VACCINATION


SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location) total_vac_in_particular_country
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
ORDER BY 2,3


--TOTAL POPULATION VS VACCINATION percentage 


SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location) total_vac_in_particular_country
	--(total_vaccinations_in_particular_country/population)*100  -- we can't do that. so need either CTE or TEMP Table. 
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
ORDER BY 2,3


										--USE CTE, Calculating vacc percentage 

with PopvsVcc(Continet, Location,  Date, Population, New_vaccination, total_vac_in_particular_country)
as
(
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location) total_vac_in_particular_country
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
--ORDER BY 2,3 --CAN'T USE ORDER BY CLAUSE IN VIEWS, INLINE FUCN, DRIVED TABLES, SUBQUERIES, CTE, OFFSET
)
SELECT *, (total_vac_in_particular_country/Population)*100
FROM PopvsVcc



										--USE TEMP, Calculating vacc percentage


DROP TABLE IF exists #PERCENT_POPULATION_VACCINATED
CREATE TABLE #PERCENT_POPULATION_VACCINATED
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
Total_vac_in_particular_country numeric
)
INSERT INTO #PERCENT_POPULATION_VACCINATED
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location) total_vac_in_particular_country
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
SELECT *, (total_vac_in_particular_country/Population)*100
FROM #PERCENT_POPULATION_VACCINATED



				--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION


CREATE OR ALTER VIEW PERCENT_POPULATION_VACCINATED AS 
SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location) total_vac_in_particular_country
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
;

SELECT *
FROM PERCENT_POPULATION_VACCINATED


-- TOTAL VACCINATION IN PARTICULAR COUNTRY --ADDED BY DATE -- USING PARTITION BY  


SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location order by dth.location, dth.date) total_vaccinations_in_particular_country
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null
ORDER BY 2,3



--Vaccination in Bangladesh

SELECT dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations, 
	SUM(CONVERT(bigint, vcc.new_vaccinations)) OVER (PARTITION BY dth.location order by dth.location, dth.date) total_vaccinations_in_BD
FROM PortfolioProject..CovidDeaths dth
JOIN PortfolioProject..CovidVaccinations vcc
	ON dth.location=vcc.location
	AND dth.date=vcc.date
	WHERE dth.continent is not null and dth.location='Bangladesh' --and vcc.new_vaccinations is not null
ORDER BY 2,3


										


 