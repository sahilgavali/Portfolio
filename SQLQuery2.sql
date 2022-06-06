--Select *
--From PortfolioProject..Covid_Vaccinations$
--Order by 3,4

Select *
From PortfolioProject..Coviddeaths$
where continent is not null
Order by 3,4


--Selecting the data Im Using.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Coviddeaths$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths$
where continent is not null
where location like '%Ireland%'
order by 1,2

--Looking at Total case Vs Population
--What % population got covid

Select Location, date, total_cases, total_deaths, (total_cases/population)*100 as PercentagePopulation
From PortfolioProject..Coviddeaths$
where continent is not null
--where location like '%Ireland%'
order by 1,2

--Highest Infection Rate in a country compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Coviddeaths$
where continent is not null
--where location like '%Ireland%'
Group by Location, Population
order by PercentPopulationInfected desc

--Number of People Died per population in a country 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..Coviddeaths$
where continent is null
--where location like '%Ireland%'
Group by Location
order by TotalDeathCount desc

--Breaking things by continents

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..Coviddeaths$
where continent is not null
--where location like '%Ireland%'
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths$
where continent is not null
--Group by date
--where location like '%Ireland%'
order by 1,2 

--Looking at Total Population vs Vaccinations

Select *
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Loooking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORder by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopsvsVac (Continent, Location, date, Population , new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORder by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac




--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORder by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualisations.

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORder by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated