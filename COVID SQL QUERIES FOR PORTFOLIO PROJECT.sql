select *
from portfolioproject..CovidDeaths
where continent IS NOT NULL
order by 3,4


--select *
--from portfolioproject..Covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
order by 1,2

--Looking at Total Cases VS Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths
where location = 'pakistan'
order by 1,2


--Looking at Total Cases VS Population
--Shows what percentage of Population got Covid

select location, date, population, total_cases, (total_deaths/population)*100 as PercentageInfected
from portfolioproject..CovidDeaths
where location = 'pakistan'
order by 1,2


--Looking at countries with Highest Rate of Infection compared to their Population

select location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths
--where location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count Per Population

select Location, MAX(cast (Total_deaths as int)) AS TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent IS NOT NULL
GROUP BY location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the Highest Death Count Per Population

select location, MAX(cast (Total_deaths as int)) AS TotalDeathCount
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent IS NULL
GROUP BY location
order by TotalDeathCount desc



--GLOBAL NUMBERS

select SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
from portfolioproject..CovidDeaths
--where location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2


--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS

WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  --GROUP BY 2,3
  WHERE dea.continent IS NOT NULL
 
  )
  SELECT*, (RollingPeopleVaccinated/population)*100 
  FROM  PopvsVac



  --TEMP TABLE

  DROP TABLE IF exists #PercentpopulationVaccinated

  CREATE TABLE #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



  INSERT INTO #PercentpopulationVaccinated
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  --GROUP BY 2,3
 -- WHERE dea.continent IS NOT NULL

  SELECT*, (RollingPeopleVaccinated/population)*100 
  FROM  #PercentpopulationVaccinated


  --Creating View to store Data for Later Visualizations

  Create View PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..Covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  --GROUP BY 2,3
  WHERE dea.continent IS NOT NULL

  SELECT *
  FROM PercentpopulationVaccinated
 




