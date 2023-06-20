--total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from data..CovidDeaths$
--where location like '%poland%'
order by 1,2


--total cases vs population

select location, date, total_cases, population, (total_cases/population) * 100 as percentage_of_population_infected
from data..CovidDeaths$
--where location like '%poland%'
order by 1,2


--infection rate compared to population

select location, population, max(total_cases) as highest_infection, max(total_cases/population) * 100 as percentage_of_population_infected
from data..CovidDeaths$
--where location like '%poland%'
group by location, population
order by percentage_of_population_infected desc


--death count per country

select location, max(cast(total_deaths as int)) as total_death_count
from data..CovidDeaths$
--where location like '%poland%'
where continent is not null
group by location
order by total_death_count desc


--death count per continent

select location, max(cast(total_deaths as int)) as total_death_count
from data..CovidDeaths$
where continent is null
group by location
order by total_death_count desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from data..CovidDeaths$
--where location like '%poland%'
where continent is not null
--group by date
order by 1,2


-- total population vs vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as peoplevaccinated
from data..CovidDeaths$ d
join data..CovidVaccinations$ v on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3


--

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, peoplevaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as peoplevaccinated
from data..CovidDeaths$ d
join data..CovidVaccinations$ v on d.location = v.location and d.date = v.date
where d.continent is not null
)
Select *, (peoplevaccinated/Population)*100
From PopvsVac


--

drop table if exists #ppv

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as peoplevaccinated
into #ppv
from data..CovidDeaths$ d
join data..CovidVaccinations$ v on d.location = v.location and d.date = v.date
where d.continent is not null

Select *, (peoplevaccinated/Population)*100
From #ppv


--create view to store data fo later visualizations

--use data

create view percentpeoplevaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as peoplevaccinated
from data..CovidDeaths$ d
join data..CovidVaccinations$ v on d.location = v.location and d.date = v.date
where d.continent is not null

select * from percentpeoplevaccinated