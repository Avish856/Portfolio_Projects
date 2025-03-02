--select * from CovidDeaths
--order by 3,4

--Select * from CovidVacinations
--order by 3,4

-- Select the data that we are using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--total cases v/s total deaths (Likelihood of dying in India)
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'I%a'
order by 1,2 


--Total cases V/S Population (Percentage of population got covid)
select location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
from CovidDeaths
where location like 'I%a'
order by 1,2 

-- Countries with high infection rate compared to population
select location,population,max(total_cases) as HighrstInfectionCount,
max((total_cases/population))*100 as InfectionPercentage
from CovidDeaths 
group by location,population
order by InfectionPercentage DESC



-- Countries with Highest Death count Per population
select location,population,max(cast(total_deaths as int)) as DeathCount,
max((total_deaths/population))*100 as InfectionPercentage
from CovidDeaths
where continent is not null
group by location,population
order by DeathCount DESC


--select continent,max(cast(total_deaths as int)) as DeathCount,
--max((total_deaths/population))*100 as InfectionPercentage
--from CovidDeaths
--where continent is not null
--group by continent
--order by DeathCount DESC



--Let's break things down by continent ****



-- Continent with highest death counts per population

select continent, max(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by continent
order by DeathCount DESC

-- ******************Global Numbers******************************

select date,sum(new_cases) as new_case,sum(cast(new_deaths as int)) as new_death,sum(cast(new_deaths as int))/sum(new_cases) --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'I%a'
where continent is not null
group by date
order by 1,2   ---(each day total across the world)

--overall across the world
select sum(new_cases) as new_case,sum(cast(new_deaths as int)) as new_death,sum(cast(new_deaths as int))/sum(new_cases) --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'I%a'
where continent is not null
order by 1,2  

------------------------------------------------------------------------------------------------

select * from CovidVacinations
--(Join)--
-- Looking at Total population v/s Vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as rolling_vaccinated
--, (rolling_vaccinated/population) as v not possible just created a column
from CovidDeaths cd
join CovidVacinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

--- with cte
with popvac(continent,location,date,population,new_vacinations,rolling_vaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as rolling_vaccinated
--, (rolling_vaccinated/population) as v not possible just created a column
from CovidDeaths cd
join CovidVacinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
select *, (rolling_vaccinated/population)*100 as total_vacc from popvac
order by 2,3


------------------ with temp table
drop table #covid --drop table if exists covid
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as rolling_vaccinated
--, (rolling_vaccinated/population) as v not possible just created a column
into #covid
from CovidDeaths cd
join CovidVacinations cv
on cd.location=cv.location and cd.date=cv.date
--where cd.continent is not null

select *,((rolling_vaccinated/population*100)) as total_vacc from #covid  


-- Creating view to store data for upcoming visualizations ----------

create or alter view percentPopulationVaccinated
as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over(partition by cd.location order by cd.location,cd.date) as rolling_vaccinated
--, (rolling_vaccinated/population) as v not possible just created a column
from CovidDeaths cd
join CovidVacinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

Select * from percentPopulationVaccinated


-------------------------------------------------------------------------------------------------
------  Creating other views fro futureuse if required ------------------------------------------
-------------------------------------------------------------------------------------------------

-- 1. View for Countries with high infection rate compared to population
create or alter view highInfection 
as
select location,population,max(total_cases) as HighrstInfectionCount,
max((total_cases/population))*100 as InfectionPercentage
from CovidDeaths 
group by location,population
--order by InfectionPercentage DESC

select * from highInfection
order by InfectionPercentage DESC

-- 2. Countries with Highest Death count Per population
create or alter view highDeath
as 
select location,population,max(cast(total_deaths as int)) as DeathCount,
max((total_deaths/population))*100 as InfectionPercentage
from CovidDeaths
where continent is not null
group by location,population
--order by DeathCount DESC

select * from highDeath
order by DeathCount DESC

-- 3. New case each day and new case v/s death ratio
create or alter view caseDeath
as
select date,sum(new_cases) as new_case,sum(cast(new_deaths as int)) as new_death,sum(cast(new_deaths as int))/sum(new_cases) as deathPercentage --total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
--order by 1,2   ---(each day total across the world)

select * from caseDeath
order by 1,2
-------------------------------------------******------------------------------------------------