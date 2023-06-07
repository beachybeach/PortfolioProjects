/*
Covid 19 Data Exploration 2021 Data
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4


-- SELECTING ALL THE DATA WE WILL BE USING

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2


-- TOTAL CASES VS. TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DEATH FROM COVID PER COUNTRY

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2


-- TOTAL CASES VS. TOTAL POPULATION
-- SHOWS PERCENTAGE INFECTED WITH COVID PER COUNTRY

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2


-- COUNTRIES WITH HIGHEST INFECTION RATE

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- HIGHEST DEATH COUNT BY CONTINENT

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
WHERE continent is not null 
--GROUP BY date
order by 1,2

-- LOOKING AT TOTAL POPULATIONS VS. VACCINATIONS


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USING CTE ON PARTITION BY IN PREVIOUS QUERY

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE	

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- CREATING VIEW TO STORE FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3