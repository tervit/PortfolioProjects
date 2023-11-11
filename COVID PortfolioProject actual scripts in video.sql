SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ukraine%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as 
	PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
Group by Location, population
order by PercentPopulationInfection desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as tota_deaths, sum(cast(new_deaths as int))/SUM(new_cases)
	*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
where continent is not null
--Group by date
order by 1, 2

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccionation, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table

DROP TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualiza

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated