--COVID-19 ANALYSIS

-- Viewing daily COVID-19 cases and deaths by location with population context
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project 2]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths for Poland
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project 2]..CovidDeaths
Where location like '%Poland%'
order by 1,2

-- Tracking COVID-19 death percentage by country over time
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
order by 1,2

-- Showing COVID-19 infection percentages over time for all locations
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project 2]..CovidDeaths
Group by location, population
Order by 4 DESC

--Showing countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Group by location
Order by 2 DESC

--Showing continet with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Group by continent
Order by 2 DESC


--GLOBAL NUMBERS

-- Showing daily global totals of COVID-19 cases, deaths, and death percentage over time
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_cases, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Group by date
Order by 1


-- Calculating global total cases, total deaths, and overall COVID-19 death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Order by 1

-- Tracking daily and cumulative COVID-19 vaccinations per country over time
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project 2]..CovidDeaths dea
Join [Portfolio Project 2]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project 2]..CovidDeaths dea
Join [Portfolio Project 2]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
From PopvsVac

--USING TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project 2]..CovidDeaths dea
Join [Portfolio Project 2]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating Views - PercentagePopulationVaccinated view

Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project 2]..CovidDeaths dea
Join [Portfolio Project 2]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

--View ContinentDeathCount
Create View ContinentDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 2]..CovidDeaths
Where continent is not null
Group by continent
