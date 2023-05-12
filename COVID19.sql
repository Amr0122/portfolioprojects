--Covid 19 Data Exploration 

Select *
From CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

SELECT 
location , date , total_cases,new_cases,total_deaths,population
FROM CovidDeaths
--WHERE location='Egypt'
ORDER BY 1,2

-- Total Cases vs Total Deaths

select  
location, count (total_cases) AS total_cases , count (total_deaths) AS total_deaths
from CovidDeaths
--WHERE date =30-04-2021
--where location = 'Egypt'
group by location
ORDER BY total_cases,total_deaths

-- Shows what percentage of population infected with Covid

SELECT
location , date ,new_cases,new_deaths, total_cases, total_deaths,(total_deaths/total_cases)* 100 as p_death
FROM CovidDeaths
WHERE location='Egypt'
ORDER BY 1,2

-- Shows what percentage of population infected with Covid SIMLE ROW
SELECT
location , date ,population,(total_cases/population)* 100 as p_population
FROM CovidDeaths
where location like '%states'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT
location ,population ,MAX (new_cases) AS M_N_CASES , MAX(total_cases) AS H_INFECTION ,MAX((total_cases/population)* 100 )as p_population
FROM CovidDeaths
--WHERE location='Egypt'
--where location like '%states'
GROUP BY location ,population
ORDER BY 5 DESC

-- Countries with Highest Death Count per Population

 SELECT 
 LOCATION , MAX (CAST(TOTAL_DEATHS AS INT)) AS TOTAL_D_MAX 
 FROM CovidDeaths
 --WHERE location='Egypt'
 WHERE continent IS  NULL
 GROUP BY location
 ORDER BY TOTAL_D_MAX DESC


-- Showing contintents with the highest death count per population
 
 SELECT 
  continent, MAX (CAST(TOTAL_DEATHS AS INT)) AS TOTAL_D_MAX 
 FROM CovidDeaths
 --WHERE LOCATION LIKE '%EGYPT%'
 WHERE continent IS NOT NULL
 GROUP BY   continent
 ORDER BY TOTAL_D_MAX DESC


-- TEST 1 

SELECT
location, MAX (total_cases ),MAX((total_cases/population)* 100)
FROM CovidDeaths
GROUP BY location
ORDER BY location

--TEST 2
SELECT
MAX((total_cases/population)* 100) ,location
FROM CovidDeaths
GROUP BY location



-- GLOBLE NUMBER

SELECT  DATE , SUM (new_cases) as total_cases,SUM( CAST (new_deaths AS INT)) as total_deaths,(SUM( CAST (new_deaths AS INT))/
SUM(new_cases))*100 AS DEATHS_P
FROM CovidDeaths
WHERE continent is not null
GROUP BY DATE
ORDER BY date

-- GLOBLE NUMBER BY CTE
 WITH CTE_P AS (
SELECT
 date ,sum (new_cases ) as sum_cases,sum (cast (new_deaths as int )) as sum_deaths
 , round (sum (cast (new_deaths as int ))/sum (new_cases )* 100,4) as p_death
FROM CovidDeaths
where continent is not null
group by date  

)
SELECT DATE,sum_cases,sum_deaths,p_death
FROM CTE_P
order by date


-- Total Population vs Vaccinations

SELECT DEA.continent, DEA.location,DEA.date,DEA.population, (VAC.new_vaccinations),
sum ( convert (int,VAC.new_vaccinations ) ) over (partition by dea.location order by dea.location,dea.date) as rolling_p_vac,
vac.total_vaccinations
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location=VAC.location
AND DEA. date=  VAC .date
where DEA.continent is not null
ORDER BY 2,3 

-- Using CTE to perform Calculation on Partition By in previous query

with p_v(continet,loaction,date,population,new_vaccinations,rolling_p_vac) 
as
(
SELECT DEA.continent, DEA.location,DEA.date,DEA.population, (VAC.new_vaccinations),
sum ( convert (int,VAC.new_vaccinations ) ) over (partition by dea.location order by dea.location,dea.date) 
as rolling_p_vac

FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location=VAC.location
AND DEA. date=  VAC .date
where DEA.continent is not null
--ORDER BY 2,3
)
select * , round ( (rolling_p_vac / population)*100 ,4)
from p_v

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percent_population_vac
create table #percent_population_vac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_p_vac numeric
)

insert into #percent_population_vac

SELECT DEA.continent, DEA.location,DEA.date,DEA.population, (VAC.new_vaccinations),
sum ( convert (int,VAC.new_vaccinations ) ) over (partition by dea.location order by dea.location,dea.date) 
as rolling_p_vac

FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location=VAC.location
AND DEA. date=  VAC .date
where DEA.continent is not null

select * , round ( (rolling_p_vac / population)*100 ,4)
from #percent_population_vac

-- Creating View to store data for later visualizations

create view percent_population_vac as
SELECT DEA.continent, DEA.location,DEA.date,DEA.population, (VAC.new_vaccinations),
sum ( convert (int,VAC.new_vaccinations ) ) over (partition by dea.location order by dea.location,dea.date) 
as rolling_p_vac

FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
ON DEA.location=VAC.location
AND DEA. date=  VAC .date
where DEA.continent is not null

select *
from percent_population_vac









