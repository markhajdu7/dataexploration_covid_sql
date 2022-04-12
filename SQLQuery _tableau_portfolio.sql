--data for the first visualization
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
--Group By date
order by 1,2

-------
--data for the second viz
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE location IN('Africa','Asia','Europe','North America','Oceania','South America')
GROUP BY location
ORDER BY TotalDeathCount DESC
--

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE location IN('Africa','Asia','Europe','North America','Oceania','South America')
GROUP BY location
ORDER BY TotalDeathCount DESC

--data for the third viz
SELECT location,population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

---
SELECT location,population,date, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location NOT IN('Africa','Asia','European Union','Europe','High income','International','Low income',
--'Lower middle income','North America','Oceania','South America','Upper middle income','World')
GROUP BY location, population,date
ORDER BY location,date

--ALTER TABLE CovidDeaths ALTER COLUMN total_deaths nvarchar(50)
--ALTER TABLE CovidDeaths ALTER COLUMN total_deaths int

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--and continent is not null 
--order by 1,2