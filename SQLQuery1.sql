/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [SQL Project Covid].[dbo].[CovidDeaths$]

  Select count(*)
  From [SQL Project Covid].[dbo].[CovidDeaths]

  Select *
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  order by 3,4

  Select *
  FROM [SQL Project Covid]..CovidVaccinations
  order by 3,4

  Select Location, date, total_cases, new_cases, total_deaths, population
  FROM [SQL Project Covid]..CovidDeaths
  Order by 1,2

  -- Total Cases vs Total Deaths

  Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Where location = 'Australia'
  Order by 1,2

  -- Total Cases vs Population (does not exclude repeat cases)
  Select Location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Where location = 'Australia'
  Order by 1,2

  -- Countries with Highest Infection Rate compared to Population
  Select Location, population, MAX(total_cases) as HighestInfectionCount
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Group by Location, population
  Order by 3 DESC


  -- Countries with Highest Death Count
  Select Location, continent, MAX(cast(total_deaths as INT)) as HighestDeathCount
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Group by Location, continent
  Order by HighestDeathCount DESC


  -- Countries with Highest Death Count per Population
  Select Location, continent, MAX(cast(total_deaths as INT)/population)*100 as DeathsPercentageofPopulation
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Group by Location, continent
  Order by DeathsPercentageofPopulation DESC


  --Continents with highest death count
  Select continent, MAX(cast(total_deaths as INT)) as ContinentDeathCount
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Group by continent
  Order by ContinentDeathCount DESC


  --Global cases Total per day
  Select date, SUM(new_cases)
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  GROUP by date
  Order by 1

  --Global cases and deaths Total per day
  Select date, SUM(new_cases), SUM(cast(new_deaths as int))
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  GROUP by date
  Order by 1

  --Global cases, deaths and Percentage of deaths per new case
  Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  GROUP by date
  Order by 1

  --Global Total cases, deaths and percentage
  Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  Order by 1


  --Join CovidDeaths with Covid Vaccinations
  Select *
  From [SQL Project Covid]..CovidDeaths as dea
  Join [SQL Project Covid]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
  Order by dea.location, dea.date

  --Total Population vs Vaccinations
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations
  From [SQL Project Covid]..CovidDeaths as dea
  Join [SQL Project Covid]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
  Order by dea.location, dea.date


   --Total Population Fully Vaccinated
  Select dea.continent, dea. date, dea.location, dea.population, vac.people_fully_vaccinated
  ,(cast(vac.people_fully_vaccinated as bigint)/dea.population)*100 as PercentagePeopleFullyVacc
  From [SQL Project Covid]..CovidDeaths as dea
  Join [SQL Project Covid]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Group by dea.continent, dea.date, dea.location, dea.population, vac.people_fully_vaccinated
  Order by dea.location


  --Temp Table
  DROP table if exists #PercentPopulationVaccinated
  Create table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Date datetime,
  Location nvarchar(255), 
  population numeric,
  people_fully_vaccinated numeric,
  PercentagePeopleFullyVacc int
  )

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea. date, dea.location, dea.population, vac.people_fully_vaccinated
  ,(cast(vac.people_fully_vaccinated as bigint)/dea.population)*100 as PercentagePeopleFullyVacc
  From [SQL Project Covid]..CovidDeaths as dea
  Join [SQL Project Covid]..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Group by dea.continent, dea.date, dea.location, dea.population, vac.people_fully_vaccinated
  Order by dea.location

 SELECT *
  From #PercentPopulationVaccinated
  Order by location, date


  --Percentage of population Fully Vaccinated by Country
 Select location, MAX(PercentagePeopleFullyVacc) as Vaccination_Percentage
  FROM #PercentPopulationVaccinated
  WHERE continent is not null
  Group by location
  Order by Vaccination_Percentage DESC

  

  
  --Creating view to store data for visualisations

  Create View  GlobalDeaths2 as
  Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
  FROM [SQL Project Covid]..CovidDeaths
  WHERE continent is not null
  GROUP by date
 
 Select *
 From GlobalDeaths2
 Order by date
  