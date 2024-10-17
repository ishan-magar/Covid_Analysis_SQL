-- Checking if The Data Has Been Uploaded
--SELECT * FROM `integrated-will-406918.Portfolio_Project.CovidVaccination_2020-2021`
--order by 3,4


-- Selcet Data that we are going to be using
Select Location, date, total_cases,new_cases,total_deaths,population From `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
order by 1,2 ;


-- Looking At Total Cases Vs Total Deaths
-- Shows Likelihood of dying if you contract COVID in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as DeathPercentage From `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Where Location like 'Nepal%'
order by 1,2 ;


-- Looking at Total Cases Vs Population
-- Percentage of Population got Covid
Select Location, date, total_cases,Population, (total_cases/Population) *100 as InfectedPercentage From `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Where Location like 'Nepal%'
order by 1,2 ;


-- Looking At Countries with Highest Infection Rate Compared to Population


Select Location, MAX(total_cases) as HighestInfectionCount ,Population, (Max(total_cases)/Population) *100 as PercentPopulationInfected From `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Group By Location, Population
order by PercentPopulationInfected desc;


-- Showing Countries with the Highest Death Count Per Population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,Population, (MAX(CAST(total_deaths AS INT)) / Population) * 100 AS PercentPopulationDeath
FROM
  `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Where continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationDeath DESC;


-- Shows Continents With Highest Death Count
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM
  `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Where continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers


-- Shows Total Date Percentage Across the Globe
Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,sum(new_deaths)/sum (new_cases) *100 as DeathPercentage
FROM
  `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021`
Where continent is not null
order by 1,2;

-- Looking at Total Populatioin vs Vaccinations

-- Using CTE
WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS int)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
  FROM  `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021` as dea
Join 
`integrated-will-406918.Portfolio_Project.CovidVaccination_2020-2021` as vac
on  
dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 From PopvsVac ;


--Creating View to store data for later

CREATE OR REPLACE VIEW `integrated-will-406918.Portfolio_Project.PopulationVaccinationView` AS
WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS INT64)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
  FROM  
    `integrated-will-406918.Portfolio_Project.CovidDeaths_2020-2021` as dea
  JOIN 
    `integrated-will-406918.Portfolio_Project.CovidVaccination_2020-2021` as vac
  ON  
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS RollingPercentage 
FROM PopvsVac;