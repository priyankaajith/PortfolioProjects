/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



--Viewing data we need for exploration, and arranging the columns from the 3rd, 4th etc.


Select *
From PortfolioProjects..coviddeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..coviddeaths
where continent is not null
order by 1,2




-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country, Death Percentage

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..coviddeaths
where location like '%canada%'
and continent is not null
order by 1,2





-- Total Cases vs Population
-- Shows what percentage of population infected with Covid, PercentPopulationInfected

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..coviddeaths
where location like '%canada%'
order by 1,2





-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..coviddeaths
--Where location like '%canada%'
Group by Location, Population
order by PercentPopulationInfected desc 



-- Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as MaxCasualities
from PortfolioProjects..coviddeaths
--Where location like '%canada%'
Group by Location
order by MaxCasualities desc 


--showing continents with the highest deaths

select continent, MAX(cast(total_deaths as int)) as MaxCasualities
from PortfolioProjects..coviddeaths
where continent is not null
Group by continent
order by MaxCasualities desc 


--Numbers Worldwide


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select *
From PortfolioProjects..covidvaccinations



--Joining both tables (Vaccinations and deaths)

Select *
From PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date

--looking at total population vs vaccinations (when join, specify which table)


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3



--get a rolling sum of the new vaccinations per location


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Creating CTE to store the above output

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
From PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date numeric,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
    as RollingPeopleVaccinated
From PortfolioProjects..coviddeaths dea
join PortfolioProjects..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View 

PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..coviddeaths dea
Join PortfolioProjects..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Create View 

MaxCasualities 
as
select continent, MAX(cast(total_deaths as int)) as MaxCasualities
from PortfolioProjects..coviddeaths
where continent is not null
Group by continent
--order by MaxCasualities desc 
