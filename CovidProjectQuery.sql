SELECT MIN(date)
FROM Covid_project.[dbo].[CovidDeaths2]
--where continent is not null
--where location = 'China'
--ORDER BY 3,4

SELECT *
FROM Covid_project.[dbo].[CovidVacinations2]
where continent is not null
ORDER BY 3,4

--Only INDIA

SELECT *
FROM Covid_project.[dbo].[CovidVacinations2]
where location = 'India'
ORDER BY 3,4



select location,date,total_cases,new_cases,total_deaths,population
FROM Covid_project.[dbo].[CovidDeaths2]
ORDER BY 1,2


--percentage of Total deaths by Total cases

select location,date,new_cases,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Covid_project.[dbo].[CovidDeaths2]
where location  like 'India%'
ORDER BY 1,2

---INDIA

---percentage of total deaths by total population
select location,date,sum(new_cases) as total_cases,new_deaths ,total_deaths
--,sum(CAST(new_deaths as bigint)) as total_deaths1
--, (sum(CAST(new_deaths as bigint))/sum(new_cases))*100 as Death_percentage
FROM Covid_project.[dbo].[CovidDeaths2]
where location  like 'India%'
group by location,date,new_deaths,total_deaths
ORDER BY 2

select MAX(CAST(total_deaths as bigint)) as final_total_deaths
FROM Covid_project.[dbo].[CovidDeaths2]
where location = 'India'



--percentage of total cases by total population

select location,date,population,new_cases,total_cases,(total_cases/population)*100 as PercentageOfPopulationInfected
--,MAX(total_cases) as final_total_case
FROM Covid_project.[dbo].[CovidDeaths2]
where location = 'India'
--group by location,date,population,new_cases,total_cases
ORDER BY 1,2

select MAX(CAST(total_cases as bigint)) as final_total_case
FROM Covid_project.[dbo].[CovidDeaths2]
where location = 'India'

-- percentage of vacination by date
select dea.location,dea.date,dea.population,vac.new_vaccinations,vac.total_vaccinations
--,MAX(total_cases) as final_total_case
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'India'
--group by location,date,population,new_cases,total_cases
ORDER BY 1,2

select MAX(CAST(total_vaccinations as bigint)) as final_total_vacinations
FROM Covid_project.[dbo].[CovidVacinations2]
where location = 'India'


--People fully vacinated
select dea.location, dea.population,MAX(CAST(vac.people_fully_vaccinated as bigint)) as people_fully_vaccinated,
(MAX(CAST(vac.people_fully_vaccinated as bigint))/dea.population)*100 as per_fully_vaccinated
-- vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'India'
group by dea.location,dea.population
order by 1

--people atleast once vacinated
select dea.location, dea.population,MAX(CAST(vac.people_vaccinated as bigint)) as people_vaccinated,
(MAX(CAST(vac.people_vaccinated as bigint))/dea.population)*100 as per_population_vaccinated
-- vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'India'
group by dea.location,dea.population
order by 1


----LET'S DO ALL THE COUNTRIES 

--country with higest infection rate

select location,population,MAX(total_cases) as HigestInfectionCount,
MAX((total_cases/population))*100 as PercentageOfPopulationInfected,
MAX(CAST(total_deaths as int)) as HigestDeathCount,
MAX((total_deaths/population))*100 as PercentageOfPopulationDied
FROM Covid_project.[dbo].[CovidDeaths2]
where continent is not null
group by location,population
ORDER BY PercentageOfPopulationInfected desc

--country with higest infection rate by date
select location,date,population,MAX(total_cases) as HigestInfectionCount,
MAX((total_cases/population))*100 as PercentageOfPopulationInfected
FROM Covid_project.[dbo].[CovidDeaths2]
where continent is not null
group by location,population,date
ORDER BY PercentageOfPopulationInfected desc

--country with higest Death Count

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Covid_project.[dbo].[CovidDeaths2]
where continent is not null
group by location
ORDER BY TotalDeathCount desc

--country with higest Death Count per population

select location,population,MAX(CAST(total_deaths as int)) as HigestDeathCount,MAX((total_deaths/population))*100 as PercentageOfPopulationDied
FROM Covid_project.[dbo].[CovidDeaths2]
group by location,population
ORDER BY PercentageOfPopulationDied desc

----LETS DO CONTINENT

--continent with higest Death Count

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Covid_project.[dbo].[CovidDeaths2]
where continent is  not null
group by continent
ORDER BY TotalDeathCount desc


----LETS DO GLOBAL COUNTS

select SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_deaths, ( SUM(cast(new_deaths as int))/ SUM(new_cases)*100) as Death_percentage
FROM Covid_project.[dbo].[CovidDeaths2]
where continent is  not null
ORDER BY 1,2 

--Total population by vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is  not null
order by 2,3

---CTE

with POPvsVAC (continent, location, date, population, New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is  not null
)
select *,(RollingPeopleVaccinated / population)*100 as VaccinatedPercentage
from POPvsVAC


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is  not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--percentage of INDIANS Fully Vacinated

SELECT dea.continent,dea.date,dea.location,dea.population, vac.total_vaccinations,vac.people_fully_vaccinated,(cast(people_fully_vaccinated as bigint)  /dea.population)*100 as percentage_of_fullVacinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'India'
ORDER BY 2,3


--percentage of people Fully Vacinated by country

SELECT dea.location,dea.population, 
--MAX(vac.total_vaccinations),
MAX(CAST(vac.people_fully_vaccinated as bigint)) as Fully_vacinated  ,
MAX(CAST(people_fully_vaccinated as bigint) /dea.population)*100 as percentage_of_fullyVacinated
FROM Covid_project.[dbo].[CovidDeaths2] dea
join Covid_project.[dbo].[CovidVacinations2] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is  not null
group by dea.location,dea.population
ORDER BY location
--ORDER BY percentage_of_fullyVacinated desc

--Median AGE of DEATH

SELECT location, MAX(median_age) as Median_age
FROM Covid_project.[dbo].[CovidVacinations2]
where continent is not null
group by location
order by Median_age desc

-- HEARTDISEASE RATE

DROP Table if exists #heart
Create Table #heart
(
location nvarchar(225),
hearth_disease numeric,
diabetes_patient numeric,
female_smokers numeric,
male_smokers numeric,
)
insert into #heart
SELECT vac.location, 
MAX(CAST(cardiovasc_death_rate as bigint)) as HEART_DISEASE,
MAX(CAST(diabetes_prevalence as bigint)) as diabetes_patient,
MAX(CAST(female_smokers as bigint)) as female_smokers, 
MAX(CAST(male_smokers as bigint)) as male_smokers 
--SUM(dea.population),(MAX(cardiovasc_death_rate) / dea.population)*100
FROM Covid_project.[dbo].[CovidVacinations2] vac
join Covid_project.[dbo].[CovidDeaths2] dea
	on vac.location =  dea.location 
	and vac.date = dea.date 
where vac.continent is not null
group by vac.location
order by HEART_DISEASE desc


select 
sum(hearth_disease) as total_hearth, (sum(hearth_disease)/300290277)*100 as percent_of_heartPatient,
sum(diabetes_patient) as total_diabetes_patient, (sum(diabetes_patient)/300290277)*100 as percent_of_diabetiesPatient,
sum(female_smokers) as total_female_smokers,(sum(female_smokers)/300290277)*100 as percent_of_femaleSmokers,
sum(male_smokers) as total_male_smokers,(sum(male_smokers)/300290277)*100 as percent_of_maleSmokers
from #heart
--order by hearth_disease desc




---Total world population
Select  max(total_cases) as Total_world_cases
--Max(population) as world_population
FROM Covid_project.[dbo].[CovidDeaths2] dea
where location = 'world'