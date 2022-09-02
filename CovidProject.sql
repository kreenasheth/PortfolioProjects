--select * from CovidDeaths
--order by 3,4

--select * from CovidVaccinations
--order by 3,4

--selecting data which we need

select location,date,population,new_cases,total_cases,total_deaths
from CovidDeaths
order by 1,2

--total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2

--total cases vs population
--percent of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as CovidInfectedPercent
from CovidDeaths
order by 1,2

--countries with highest infection rate compared to population 
select location,max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as PercentPopulationInfected
from CovidDeaths
group by location
order by PercentPopulationInfected desc

--countries with highest death count per population
select location,max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- global numbers for each date
select date,sum(new_cases) as Totalnewcase,sum(cast(new_deaths as int)) as totalnewdeath , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathByPercent
from CovidDeaths
where continent is not null
group by date
order by 1

-- total newcase,newdeath 
select sum(new_cases) as Totalnewcase,sum(cast(new_deaths as int)) as totalnewdeath , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathByPercent
from CovidDeaths
where continent is not null
order by 1

-- continent wise deathcount
select continent ,sum(cast(new_deaths as int)) 
from CovidDeaths
where continent is not null
group by continent

-- population vs vaccination
--so joining 2 table
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by date
-------------------------------------

select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 3,2

-- cumulative addition of sum values
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 3,2

-- use cte

with popvsvac(continent,date,location,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,( rollingpeoplevaccinated/population)*100
from popvsvac


-- tEMP table
drop table if exists temp
create table temp 
(continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into temp
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,( rollingpeoplevaccinated/population)*100
from temp

-- creating view to store data for later visualizations

create view percentpopulationvaccinated as 
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,( rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated