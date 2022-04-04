select *
from Covid_deaths
order by 2,3

select Location, date, total_cases, new_cases, total_deaths, population
From Project_Portfolio..Covid_deaths
order by 1,2

-- Looking at Total Deaths vs Total Cases

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Project_Portfolio..Covid_deaths
order by 1,2

-- Looking at Total Deaths vs Total Cases 
-- Brazil

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Project_Portfolio..Covid_deaths
where location like '%brazil%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population

select Location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
From Project_Portfolio..Covid_deaths
where location like '%brazil%'
and continent is not null
order by 1,2

-- Looking at Countries with Higehst Infection Rate campared to Population

select Location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as percentage_population_infected
From Project_Portfolio..Covid_deaths
--where location like '%brazil%'
group by location, population
order by percentage_population_infected desc

-- Showing Countries with Highest Death Count per Population

select Location, population, MAX(cast(total_deaths as int)) as Total_death_count
From Project_Portfolio..Covid_deaths
--where location like '%brazil%'
group by Location, population
order by Total_death_count desc


-- Breaking by Continents

select continent, MAX(cast(total_deaths as int)) as Total_death_count
From Project_Portfolio..Covid_deaths
--where location like '%brazil%'
where continent is not null
group by continent
order by Total_death_count desc

-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From Project_Portfolio..Covid_deaths
--where location like '%brazil%'
where continent is not null
group by date
order by 1,2

-- total 

select sum(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From Project_Portfolio..Covid_deaths
--where location like '%brazil%'
where continent is not null
--group by date
order by 1,2

-- JOINING TABLES

select *
from Project_Portfolio..Covid_vaccination

select *
from Project_Portfolio..Covid_deaths dea
join Project_Portfolio..Covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccionation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Project_Portfolio..Covid_deaths dea
join Project_Portfolio..Covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USING CTE

WITH PopsvsVac (continent, Location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Project_Portfolio..Covid_deaths dea
join Project_Portfolio..Covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/population)*100
from PopsvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Popultion numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Project_Portfolio..Covid_deaths dea
join Project_Portfolio..Covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/Popultion)*100
from #PercentPopulationVaccinated

-- CREATING VIEWS to store data for later visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, 
dea.date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Project_Portfolio..Covid_deaths dea
join Project_Portfolio..Covid_vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3