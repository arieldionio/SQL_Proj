-- Global Deaths
WITH CTE1 AS (
SELECT *
FROM CovidDeaths
WHERE total_cases IS NOT NULL
	AND total_deaths IS NOT NULL),

CTE2 AS (
SELECT 
	SUM(total_cases) AS TotalCases, 
	SUM(CAST(total_deaths AS int))  AS TotalDeaths
FROM CTE1)

SELECT 
	TotalCases, 
	TotalDeaths, 
	(TotalDeaths/TotalCases) * 100 AS DeathPerc
FROM CTE2

--Total cases vs Total deaths in the Philippines (chances of dying after contracting Covid) sorted by date.
SELECT Continent, Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases) * 100 AS DeathPerc
FROM CovidDeaths
WHERE Location LIKE '%Philippines%' AND Continent IS NOT NULL
ORDER BY Date

--Total cases vs Population
SELECT Continent, Location, Date, Total_cases, Total_deaths, (Total_cases/Population) * 100 AS PercPopInfected
FROM CovidDeaths--with NULL values	

-- Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(Total_cases) AS HighestInfectionCount, MAX((Total_cases/Population))*100 AS PercPopInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercPopInfected DESC

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population
SELECT Continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Global Numbers by Date
SELECT Date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

--Joining Population vs Vaccination per Country
SELECT  de.location, MAX(de.population) as CountryPop , MAX(va.total_vaccinations) as Vaccinated, MAX(de.total_cases) as Infected
FROM CovidDeaths de
JOIN CovidVaccinations va
ON de.location = va.location
WHERE va.total_vaccinations IS NOT NULL AND va.total_vaccinations != 0 AND de.continent IS NOT NULL
GROUP BY de.location,va.total_vaccinations,de.total_cases

SELECT de.location, MAX(de.population) as CountryPop , MAX(CAST(va.total_vaccinations as float )) as Vaccinated, MAX(de.total_cases) as Infected
FROM CovidDeaths de
JOIN CovidVaccinations va
ON de.location = va.location and de.date = va. date 
WHERE va.total_vaccinations IS NOT NULL AND va.total_vaccinations != 0 AND de.continent IS NOT NULL AND de.total_cases IS NOT NULL
GROUP BY de.location
ORDER BY Vaccinated

--USING CTE 
WITH CTE_vaccs AS ( 
SELECT de.location, MAX(de.population) as CountryPop , MAX(va.total_vaccinations) as Vaccinated, MAX(de.total_cases) as Infected
FROM CovidDeaths de
JOIN CovidVaccinations va
ON de.location = va.location
WHERE va.total_vaccinations IS NOT NULL AND va.total_vaccinations != 0 AND de.continent IS NOT NULL AND de.total_cases IS NOT NULL
GROUP BY de.location),

-- Percentage of Vaccinated individuals vs Country Population
CTE_vaccperc AS (
SELECT *, (Vaccinated/CountryPop) * 100 AS VaccPerc
FROM CTE_vaccs)

--Percentage of Infected individuals vs Country Population
SELECT *, (Infected/CountryPop) * 100 AS InfectedPerc
FROM CTE_vaccperc

--VIEWS
CREATE VIEW ARIEL AS
(SELECT * FROM CovidDeaths  WHERE total_deaths IS NOT NULL AND total_cases IS NOT NULL)


