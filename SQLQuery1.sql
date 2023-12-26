select *
from CovidDeath
order by 3,4

select *
from CovidVaccination
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
Where location like '%states%'
order by 1, 2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from CovidDeath
Where location like '%states%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectedPercentage
From CovidDeath
Group by location, population
order by InfectedPercentage desc

-- Showing Countries with Highest Death Count per Population

Select Location, Population, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population)*100) as DeathPercentage
From CovidDeath
Where continent is not null
Group by location, population
order by HighestDeathCount desc

-- Let's break thing up by continent 

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeath
Where continent is not null
Group by continent
order by HighestDeathCount desc


--Global numbers

Select date, sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeath
--where location like '%states%'
where continent is not null
Group by date
order by 1, 2

-- Total Global Number & Death percentage
Select sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeath
--where location like '%states%'
where continent is not null
--Group by date
order by 1, 2


--Looking at total population v.s. total vaccination

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(convert(int, Vac.new_vaccinations)) over (partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath Dea 
Join PortfolioProject..CovidVaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
order by 2, 3


-- CTE Table to perform Calculation on Partitioni by in previous query.

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(convert(int, Vac.new_vaccinations)) over (partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath Dea 
Join PortfolioProject..CovidVaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as 'Percentage Of People Vaccinated'
From PopvsVac




-- Temp Table

Drop table if EXISTS #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(convert(int, Vac.new_vaccinations)) over (partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath Dea 
Join PortfolioProject..CovidVaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From #PercentagePopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentagePopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, SUM(convert(int, Vac.new_vaccinations)) over (partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath Dea 
Join PortfolioProject..CovidVaccination Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
Where dea.continent is not null
--order by 2, 3


