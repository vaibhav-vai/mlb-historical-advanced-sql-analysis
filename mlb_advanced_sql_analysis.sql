-- PART I: SCHOOL ANALYSIS

-- 1. View the schools and school details tables
select * from schools;
select * from school_details;

-- 2. In each decade, how many schools were there that produced players?
select floor(yearid/10)*10 as decade, count(distinct schoolid) as num_school
from schools
group by decade
order by decade;

-- 3. What are the names of the top 5 schools that produced the most players?
select s.schoolid, sd.name_full, count(distinct s.playerid) as players_num
from schools s left join school_details sd
	on s.schoolid = sd.schoolid
group by s.schoolid, sd.name_full
order by count(s.schoolid) desc
limit 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
with top_school as (select floor(s.yearid/10)*10 as decade, s.schoolid, sd.name_full, count(distinct s.playerid) as players_num, 
							row_number() over(partition by floor(s.yearid/10)*10 order by count(distinct s.playerid) desc) as school_rank
					from schools s left join school_details sd
						on s.schoolid  = sd.schoolid
					group by decade, s.schoolid, sd.name_full
					order by decade)

select *
from top_school
where school_rank < 4;


-- PART II: SALARY ANALYSIS

-- 1. View the salaries table
select * from salaries;

-- 2. Return the top 20% of teams in terms of average annual spending
with aas as (select teamid, sum(salary)/count(distinct yearid) as avg_annual_spending,
				ntile(5) over(order by sum(salary)/count(distinct yearid) desc) as aas_percentile
			from salaries
			group by teamid)
select *
from aas
where aas_percentile = 1;

-- 3. For each team, show the cumulative sum of spending over the years
with yt as (select teamid, yearid, sum(salary) as total_salary
			from salaries
			group by teamid, yearid
			order by teamid, yearid
			)

select teamid, yearid,
		sum(total_salary) over(partition by teamid order by yearid) as cummulative_sum
from yt
order by teamid, yearid;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
with yt as (select teamid, yearid, sum(salary) as total_salary
			from salaries
			group by teamid, yearid
			order by teamid, yearid
			),
	cs as (select teamid, yearid,
					sum(total_salary) over(partition by teamid order by yearid) as cummulative_sum
			from yt
			order by teamid, yearid),
	rn as (select teamid, yearid, cummulative_sum,
					row_number() over(partition by teamid order by cummulative_sum) as rn
			from cs
			where cummulative_sum > 1000000000)
			
select teamid, yearid, cummulative_sum
from rn
where rn=1;


-- PART III: PLAYER CAREER ANALYSIS

-- 1. View the players table and find the number of players in the table
select * from players;
select count(playerid) from players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
with years as (select playerid, birthyear, 
						extract(year from debut) as debut_year, 
						extract(year from finalgame) as final_year
				from players)

select playerid,
	   debut_year - birthyear as age_at_debut,
	   final_year - birthyear as age_at_lastgame,
	   final_year - debut_year as career_length
from years
where debut_year - birthyear is not null
order by career_length desc;

-- 3. What team did each player play on for their starting and ending years?
select p.namegiven,
		s.yearid as starting_year, s.teamid as starting_team,
		e.yearid as ending_year, e.teamid as ending_year
from players p inner join salaries s
						on p.playerid = s.playerid and 
						extract(year from p.debut) = s.yearid
			   inner join salaries e
						on p.playerid = e.playerid and 
						extract(year from p.finalgame) = e.yearid;

-- 4. How many players started and ended on the same team and also played for over a decade?
with teams as (select p.playerid, p.namegiven,
						s.yearid as starting_year, s.teamid as starting_team,
						e.yearid as ending_year, e.teamid as ending_team
				from players p inner join salaries s
										on p.playerid = s.playerid and 
										extract(year from p.debut) = s.yearid
							   inner join salaries e
										on p.playerid = e.playerid and 
										extract(year from p.finalgame) = e.yearid)

select *
from teams
where starting_team = ending_team
	and ending_year - starting_year > 9;
	

-- PART IV: PLAYER COMPARISON ANALYSIS

-- 1. View the players table
select * from players;

-- 2. Which players have the same birthday?
with bn as (select make_date(birthyear::int, birthmonth::int, birthday::int) as birthday,
					namegiven
			from players)
			
select birthday, string_agg(namegiven, ', ') as players
from bn
where birthday is not null
group by birthday
order by birthday;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
SELECT	s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) * 100.0/ COUNT(s.playerID), 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END)  * 100.0/ COUNT(s.playerID), 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END)  * 100.0/ COUNT(s.playerID), 1) AS bats_both
FROM	salaries s LEFT JOIN players p
		ON s.playerID = p.playerID
GROUP BY s.teamID;

-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
with hw as (select floor(extract(year from debut)/10)*10 as decade,
					avg(height) as avg_height, avg(weight) as avg_weight
			from players
			group by decade
			order by decade)
			
select decade,
	avg_height - lag(avg_height) over(order by decade) as height_diff,
	avg_weight - lag(avg_weight) over(order by decade) as weight_diff
from hw
where decade is not null;