

SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_Deaths, population
FROM CovidDeaths$
ORDER BY 1,2

-- Look at Total Cases vs Total Deaths
-- Shows percentage of death when contracting COVID for each country

SELECT location, date, total_cases,total_Deaths, (Total_deaths/Total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1,2

-- Reviewing total cases vs population
-- Shows what percentage of the population has contracted COVID

SELECT location, date, total_cases,population, (total_cases/population) *100 AS PercentOfPopulationInfected
FROM CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1,2

-- Look at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)* 100 AS PercentOfPopulationInfected 
FROM CovidDeaths$
--WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentOfPopulationInfected DESC 

-- Showing the countries with the largest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location	
ORDER BY DeathCount DESC


--Continents with the highest death count

SELECT continent, MAX(CAST(total_deaths as int)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent	
ORDER BY DeathCount DESC


--True death count by continent
SELECT location, MAX(CAST(total_deaths as int)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location	
ORDER BY DeathCount DESC


-- GLOBAL NUMBERS

-- Total cases, deaths and percentage
SELECT  SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  --total_cases,total_Deaths, (Total_deaths/Total_cases) *100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations, SUM(CAST(vacs.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) 
as RollingVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vacs
ON dea.location = vacs.location
AND dea.date = vacs.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE for Total Population that has been vaccinated

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations, SUM(CAST(vacs.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) 
as RollingVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vacs
ON dea.location = vacs.location
AND dea.date = vacs.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinated/Population) *100 AS PercentageVaccinated
FROM PopvsVac



-- Temp table for same query as above. 2nd option

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_Vaccinations int,
RollingVaccinated int
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacs.new_vaccinations, SUM(CAST(vacs.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER by dea.location, dea.date) 
as RollingVaccinated
FROM CovidDeaths$ AS dea
JOIN CovidVaccinations$ AS vacs
ON dea.location = vacs.location
AND dea.date = vacs.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinated/Population) *100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW ContinentsWithLargestDeathCount as
SELECT continent, MAX(CAST(total_deaths as int)) AS DeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent	
--ORDER BY DeathCount DESC
