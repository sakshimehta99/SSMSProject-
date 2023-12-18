 select *
 from PortfolioProject..CovidDeaths
 --where continent is not null
 order by 3,4 

 --select *
 --from PortfolioProject..CovidDeaths
 --order by 3,4

 -- selecting relevant columns

 select Location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
  where continent is not null
 order by 1,2

 -- total cases vs total deaths
 -- shows the likelihood of dying if you get covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

-- Total cases vs population
-- % of population got covid
select Location, date, population, total_cases,  (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like 'India'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc


-- Looking at countries with highest death count per population
select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
 where continent is not null
group by Location, population
order by TotalDeathCount desc

-- lets analyze by continent.

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
 where continent is null
group by location
order by TotalDeathCount desc

-- continents with highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCounts desc


-- global numbers

select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Joining the vaccine table here
select * 
from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date

--- Looking at total popoulation vs vaccinations

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 
order by 2,3

-- rolling number for bew vaccinations
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100

from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 
order by 2,3

-- USE CTE

with popvsvac as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100

from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 from popvsvac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated 

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
--where CD.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--- Creating views to store data for later visualizations

Create View PercentPopulationVaccinated as 
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100

from PortfolioProject..CovidDeaths CD
join 
PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD.date = CV.date
where CD.continent is not null 


select * from PercentPopulationVaccinated