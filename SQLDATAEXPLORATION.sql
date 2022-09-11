--Select *
--from portfolio ..CovidDeaths
--order by 3,4

----Select *
----from portfolio ..CovidVaccinations
----order by 3,4

----Select Data that we are going to be using
--Select Location,date,total_cases,new_cases,total_deaths,population
--from portfolio ..CovidDeaths
--order by 1,2

----Looking at Total cases Vs Total Deaths

--Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--from portfolio ..CovidDeaths
--Where location like '%states%'
--order by 1,2

----Looking at Total cases vs Population
----Shows what percentage of pouplation got covid
--Select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationinfected
--from portfolio ..CovidDeaths
----Where location like '%states%'
--order by 1,2

---- Which Country has the highest infection rate compare to population
--Select Location,population,MAX(total_cases)as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationinfected
--from portfolio ..CovidDeaths
----Where location like '%states%'
--group by location,population
--order by PercentPopulationinfected desc

---- Showing Countries with Highest Death Count per Population
--Select Location,MAX(cast(total_deaths as int))as TotalDeathCount
--from portfolio ..CovidDeaths
----Where location like '%states%'
--where continent is not null
--group by location
--order by TotalDeathCount desc

---- Let's break things down by continent
--Select continent,MAX(cast(total_deaths as int))as TotalDeathCount
--from portfolio ..CovidDeaths
----Where location like '%states%'
--where continent is not null
--group by continent
--order by TotalDeathCount desc

----Showing continents with the highest Death Count per population

--Select continent,MAX(cast(total_deaths as int))as TotalDeathCount
--from portfolio ..CovidDeaths
----Where location like '%states%'
--where continent is not null
--group by continent
--order by TotalDeathCount desc

----Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolio..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
---- Total Population vs Vaccinations
---- Shows Percentage of Population that has recieved at least one Covid Vaccine

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From portfolio..CovidDeaths dea
--Join portfolio..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


---- Using CTE to perform Calculation on Partition By in previous query

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From portfolio..CovidDeaths dea 
--Join portfolio..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)
--Select *, (RollingPeopleVaccinated/Population)*100
--From PopvsVac



---- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--Insert into #PercentPopulationVaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From portfolio..CovidDeaths dea 
--Join portfolio..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
----where dea.continent is not null 
----order by 2,3

--Select *, (RollingPeopleVaccinated/Population)*100
--From #PercentPopulationVaccinated




---- Creating View to store data for later visualizations

--Create View PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From portfolio..CovidDeaths dea 
--Join portfolio..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 