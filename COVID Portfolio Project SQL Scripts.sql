select *
from CovidDeaths
where continent is not null
order by 3,4 

--select *
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract COVID in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
-- where location like '%states%'
where continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows percentage of population that has contracted COVID
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
-- where location like '%states%'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Looking at countries with highest death rate compared to population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Break down by continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Show continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 as DeathPercentage
from CovidDeaths
where continent is null
group by location, population
order by DeathPercentage desc

-- Global Numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Looking at total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE Example
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVac)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (CumulativeVac/Population)*100 as VacRate
From PopvsVac
order by 2,3

-- Temp Table Example
Drop table if exists #PercentPopulationVaccianted
Create Table #PercentPopulationVaccianted
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_Vacciantions numeric,
Rolling_People_Vaccinated numeric
)
Insert into #PercentPopulationVaccianted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From #PercentPopulationVaccianted
order by 2,3

-- Create Views to Store Data for Later Visualizations
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as CumulativeVac
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated