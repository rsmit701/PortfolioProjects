Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

Select Location, date, new_cases, total_cases, total_deaths, population 
from
PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in Jamaica

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'Jamaica' and total_deaths is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid in Jamaica vs USA

Select Location, date, total_deaths, population, (total_deaths/population) * 100 as CovidMortality
From PortfolioProject..CovidDeaths
where location = 'Jamaica' and total_deaths is not null
order by 1,2

Select Location, date, total_deaths, population, (total_deaths/population) * 100 as CovidMortality
From PortfolioProject..CovidDeaths
where location = 'United States' and total_deaths is not null
order by 1,2


--Looking at when Jamaica had its highest death count
Select Location, date, MAX(total_deaths) as HighestDeathCount
From PortfolioProject..CovidDeaths
where location = 'Jamaica' and continent is not null
group by location, total_deaths, date
order by HighestDeathCount desc


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, population
order by PercentPopulationInfected desc


--Showing Countries with the Highest Death Count per Population


Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by HighestDeathCount desc


--Lets Break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS vs USA vs JAMAICA
 (1.26 %)
--Global
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Global Numbers Ranked by DeathPercentage per country
Select location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by DeathPercentage desc


--Jamaica (2.2% death percentage, ranked 40th in the world)
Select location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location = 'Jamaica'
group by location
order by 1,2


--USA (1.3% death percentage, ranked 83rd in world) (Better than Jamaica's Rate)
Select location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location like '%states'
group by location
order by 1,2


Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null
order by 2,3


--Looking at total population vs Vaccinations of Jamaica as of April 6th (17.6%) compared to the USA (May need to convert to BIGINT instead of INT to avoid arithmetic overflow error)
--Could have used total_vaccinations but I wanted to test a theory, which worked!

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and d.location = 'Jamaica'
order by 2,3


Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and d.location like '%States'
order by 2,3

--Use CTE (Cannot have an ORDER BY clause in CTE)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationProgression)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and New_Vaccinations is not null
--order by 2,3
)
Select *, (VaccinationProgression/Population) * 100
from PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationProgression numeric
)

INSERT INTO #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and New_Vaccinations is not null
--order by 2,3

Select *, (VaccinationProgression/Population) * 100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated














--Looking at top 4 continents in terms of new vaccinations

Select d.continent, d.location, d.date, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null
and (v.date between '2020-01-01' and '2021-12-31')
order by 5 desc
 





 --Creating views to store for later visualization

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated


Create View DeathPercentage as 
Select location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location
--order by DeathPercentage desc

Select * 
from DeathPercentage
order by DeathPercentage desc



Create View VaccinationProgressionJA as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and d.location = 'Jamaica'
--order by 2,3


Select * 
from VaccinationProgressionJA
where new_vaccinations is not null


Create View VaccinationProgressionUS as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(bigint,v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date)
as VaccinationProgression
from PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null and d.location like '%states%'
--order by 2,3

Select * 
from VaccinationProgressionUS
where new_vaccinations is not null


Create View CovidMortalityJA as 
Select Location, date, total_deaths, population, (total_deaths/population) * 100 as CovidMortality
From PortfolioProject..CovidDeaths
where location = 'Jamaica' and total_deaths is not null
--order by 1,2

Select *
from CovidMortalityJA

Create View CovidMortalityUS as 
Select Location, date, total_deaths, population, (total_deaths/population) * 100 as CovidMortality
From PortfolioProject..CovidDeaths
where location = 'United States' and total_deaths is not null
--order by 1,2

Select *
from CovidMortalityUS

