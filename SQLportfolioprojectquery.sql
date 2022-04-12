--All distinct location
SELECT iso_code,continent,location, MAX(total_cases) as TotalInfectedPeople
FROM CovidDeaths
GROUP BY iso_code,location,continent
ORDER BY 3,4
--Select only countries, filter out continents and other - CovidDeaths table
SELECT iso_code,continent,location as country, MAX(total_cases) as TotalInfectedPeople
FROM CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY iso_code,location,continent
ORDER BY location

----All distinct loaction
SELECT iso_code,continent,location, MAX(total_vaccinations) as TotalVaccinations
FROM CovidVaccinations
GROUP BY iso_code,continent,location
ORDER BY location

--Select only countries, filter out continents and other - CovidVaccinations table
SELECT iso_code,continent,location, MAX(total_vaccinations) as TotalVaccinations
FROM CovidVaccinations
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY iso_code,continent,location


--Select data that I am going to be using
SELECT location, date, total_cases, new_cases, total_deaths 
FROM CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
ORDER BY 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathhPercentage
FROM CovidDeaths
WHERE location='Hungary'
ORDER BY 1,2

--Looking at total cases  vs population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases ,(total_cases/population)*100 as PercentPopulationInfected 
FROM CovidDeaths
WHERE location='Hungary'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing counties with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE location IN('Africa','Asia','Europe','North America','Oceania','South America')
GROUP BY location
ORDER BY TotalDeathCount DESC

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population
--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidDeaths
--WHERE location IN('Africa','Asia','Europe','North America','Oceania','South America')
--GROUP BY continent
--ORDER BY TotalDeathCount 

--Global numbers

--SELECT date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathhPercentage
--FROM CovidDeaths
--WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
--'Lower middle income','North America','Oceania','South America','Upper middle income','World')
----GROUP BY date
--ORDER BY 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
--Group By date
order by 1,2

--Looking at total population vs vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingTotalPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingTotalPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingTotalPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
--ORDER BY 2,3
)
SELECT*,(RollingTotalPeopleVaccinated/population)*100
FROM PopvsVac

--Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingTotalPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingTotalPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')

SELECT*,(RollingTotalPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view for later data visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingTotalPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')

SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2,3



--ALTER TABLE CovidDeaths ALTER COLUMN total_deaths nvarchar(50)
--ALTER TABLE CovidDeaths ALTER COLUMN total_deaths int

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2


--SELECT CONVERT(int,CovidDeaths.total_deaths)(total_deaths/2)
--FROM CovidDeaths

