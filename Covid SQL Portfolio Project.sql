
-- Looking at Total Cases Vs Total Deaths in Poland

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Test.dbo.covid_deathsCSV
where location = 'poland'
order by 1,2 


-- Shows what Population % got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationSick
from Test.dbo.covid_deathsCSV
--where location = 'poland'
order by 1,2


--Looking at countries with higest infection % vs Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopInfected
from Test.dbo.covid_deathsCSV 
group by population, location
order by PercentofPopInfected DESC


-- Showing countries with the highest death count per population

Select location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentofPopDeaths
from Test.dbo.covid_deathsCSV
where continent IS NOT NULL
group by population, location
order by HighestDeathCount DESC


--Let's break things down by continent
--Showing the continents with the highest death count

Select continent, MAX(Total_deaths) as TotalDeathCount
from Test.dbo.covid_deathsCSV
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Test.dbo.covid_deathsCSV
where continent is not null
order by 1,2  


--Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccs
--(RollingVaccs/population)*100
from Test.dbo.covid_deathsCSV dea
JOIN Test.dbo.covid_vaccsCSV vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3


--Using CTEs

with PopvsVacs (Continent, location, date, population, new_vaccinations, RollingVaccs)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccs
--(RollingVaccs/population)*100
from Test.dbo.covid_deathsCSV dea
JOIN Test.dbo.covid_vaccsCSV vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 2,3
	)

select *, (RollingVaccs/population)*100 as RollingVaccsPercentage
from PopvsVacs
order by 2,3


--Using Temp Table 

drop table if exists #PercentPopVacc
Create Table #PercentPopVacc
(
continent nvarchar(50), 
location nvarchar(50),
date datetime, 
population float,
new_vaccinations varchar(50),
RollingVaccs numeric)

Insert into #PercentPopVacc 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccs
--(RollingVaccs/population)*100
from Test.dbo.covid_deathsCSV dea
JOIN Test.dbo.covid_vaccsCSV vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
-- order by 2,3
	

select *, (RollingVaccs/population)*100 as RollingVaccsPercentage
from #PercentPopVacc
order by 2,3


--Creating view to store data for vizualizations

Use Test
GO
Create View GlobalNumbers0
as 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Test.dbo.covid_deathsCSV
--where location = 'poland'
--where continent is not null
--group by date
--order by 1,2  
