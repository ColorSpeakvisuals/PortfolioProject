SELECT * FROM dbo.[CovidDeaths]


---Code from my formal file---

---I altered some records datatype for it to be imported successfully---

SELECT * FROM dbo.[CovidVaccinations]
WHERE continent is not null
ORDER BY 3, 4



SELECT * FROM PortfolioProject..[CovidDeaths]
ORDER BY 3, 4

---Select Data we are going to be using---

SELECT Location, date, total_cases, New_cases, total_deaths, population FROM PortfolioProject..[CovidDeaths]
ORDER BY 1, 2

---Looking at Total Cases vs Total Deaths---
---Shows the likelihood of dying if you contract covid in your country---

SELECT Location, date, total_cases, total_deaths, CAST (total_deaths AS nvarchar(50)), (total_deaths/total_cases)*100 AS DeathPercentage FROM PortfolioProject..[CovidDeaths]
WHERE location = 'United States'
ORDER BY 1, 2 


---Looking at the Total cases vs Population
---Shows what percentage of population got covid---

SELECT Location, date,population, total_cases,  (total_cases/population)*100 AS PercentagePopulationInfected FROM PortfolioProject..[CovidDeaths]
---WHERE location = 'United States'
ORDER BY 1, 2


---Looking at the countries with highest infection rate compare to Population---

SELECT Location, Population, MAX(total_cases) AS HighestInfectiionCount,  MAX((total_cases/population))*100 AS PercentagePopulationInfected FROM PortfolioProject..[CovidDeaths]
---WHERE location = 'United States'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC

---Showing Countries with the highest death per population---

SELECT Location, MAX(total_deaths) AS HighestDeathCount FROM PortfolioProject..[CovidDeaths]
--WHERE location = 'United States'
GROUP BY Location
ORDER BY  HighestDeathCount DESC

--To Instantly convert datatype you can use CAST command as shown below

--SELECT Location, MAX(cast(total_deaths AS int)) AS HighestDeathCount FROM PortfolioProject..[CovidDeaths]
--WHERE location = 'United States'
--GROUP BY Location
--ORDER BY  HighestDeathCount DESC




SELECT location, MAX(total_deaths) AS HighestDeathCount FROM PortfolioProject..[CovidDeaths]
---WHERE location = 'United States'
WHERE continent is null
GROUP BY location
ORDER BY  HighestDeathCount DESC

---LET'S BREAK THINGS DOWN BY CONTINENT---

SELECT continent, MAX(total_deaths) AS HighestDeathCount FROM PortfolioProject..[CovidDeaths]
---WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY  HighestDeathCount DESC


--GLOBAL NUMBERS--
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / SUM(new_cases)*100 as DeathPercentage FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--looking at the Total Population vs Vaccination

--NOW JOINING THE TWO TABLES TOGETHER--
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
--I have to cast vac.new_vaccination as int for it run as due to the operand error shown--
--You can as well use CONVERT as well as shown below--
--SUM(CONVERT(int, vac.new_vaccinations))--
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3




--USE CTE
WITH PopVsVac (continent, location, date, population, new_vacciantions, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
--I have to cast vac.new_vaccination as int for it run as due to the operand error shown--
--You can as well use CONVERT as well as shown below--
--SUM(CONVERT(int, vac.new_vaccinations))--
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
 SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopVsVac


 --TEMP TABLE

 DROP TABLE if exists #PercentagePopulationVaccinated 
-- (This DROP TABLE is important when you have to alter or change something in Temp Table you already created)
 CREATE TABLE #PercentagePopulationVaccinated
 (
 Continet nvarchar(255),
 Location nvarchar(255),
 Date date,
 Population nvarchar(255),
 New_vacciantion nvarchar(255),
 RollingPeopleVaccinated numeric,
 )
 INSERT INTO #PercentagePopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
--I have to cast vac.new_vaccination as int for it run as due to the operand error shown--
--You can as well use CONVERT as well as shown below--
--SUM(CONVERT(int, vac.new_vaccinations))--
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
 SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentagePopulationVaccinated



 --Creating View to store data for later visualization

 CREATE VIEW PercentagePopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST (vac.new_vaccinations AS int))
--I have to cast vac.new_vaccination as int for it run as due to the operand error shown--
--You can as well use CONVERT as well as shown below--
--SUM(CONVERT(int, vac.new_vaccinations))--
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac 
ON dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentagePopulationVaccinated