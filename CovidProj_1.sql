--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

-- likelihood of dying in your country.
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location like '%singapore%'
--order by 1,2

-- Percent of population has covid
--Select location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--where location like '%singapore%'
--order by 1,2

-- find countries with highest cases per population
--Select Location, Population, max(total_cases) as HighestInfectCount, Population, Max((total_cases/Population))*100
--	as PercentPopInfected
--From PortfolioProject..CovidDeaths
----where location like '%singapore%'
--Group by Location, Population
--order by PercentPopInfected desc

---- countries with highest death count per pop
--Select Location, max(cast(total_deaths as int)) as totaldeathcount
--From PortfolioProject..CovidDeaths
----where location like '%singapore%'
--where continent is not null
--Group by Location
--order by totaldeathcount desc

-- countries with highest death count per pop by CONTINENT
Select continent, max(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%singapore%'
where continent is not null
Group by Continent
order by totaldeathcount desc

-- countries with highest death count per pop by LOCATION
Select location, max(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%singapore%'
where continent is null
Group by Location
order by totaldeathcount desc

--Global numbers aggregated
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%singapore%'
--group by date
order by 1,2

-- Looking at total pop. vs vaccinations + accumulative
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by location, dea.Date ) as AccumulatedVaccinations,
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE (common table expressions)
With PopvsVac (continent, Location, date, population, new_vaccinations, AccumulatedVaccinations)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date ) as AccumulatedVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%singapore%'

--order by 2,3
)
select *, (AccumulatedVaccinations/population)*100
from Popvsvac

-- Temp Table

drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AccumulatedVaccinations numeric
)

insert into #PercentPopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date ) as AccumulatedVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%singapore%'

select *, (AccumulatedVaccinations/population)*100
from #PercentPopVaccinated

-- creating view to store data for later visualizations

Create View PercentPopVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date ) as AccumulatedVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%singapore%'
--order by 2,3

select *
from PercentPopVaccinated