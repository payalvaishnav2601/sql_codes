## Create Database
create database Reportanalytics;
use reportanalytics;

## Create Table 1
create table opportunity (
Account_ID VARCHAR (200), 
Created_by_lead_conversion VARCHAR (200),
Fiscal_Quarter INT, 
Fiscal_Year INT, 
Forecast_Category VARCHAR(200), 
Forecast_Category1 VARCHAR(200),
Industry VARCHAR(200), 
Lead_source VARCHAR(200), 
Opportunity_ID VARCHAR(200), 
Order_finalized VARCHAR(200), 
Record_type_id VARCHAR(200),
Stage VARCHAR(200), 
won varchar(200), 
amount Decimal (10,2),
expected_amount Decimal (10,2),
Probability VARCHAR (200)
);

# Create Table 2
create table leads (
Converted VARCHAR (200), 
Converted_account_ID VARCHAR (200),
Converted_opportunity_ID VARCHAR(200), 
Industry VARCHAR(200),
Lead_Id VARCHAR(200), 
Lead_source VARCHAR(200),
Lead_record_type VARCHAR(200), 
Record_type_id VARCHAR(200), 
Status_1 VARCHAR(200), 
Status_simplifed VARCHAR(200), 
Converted_accounts VARCHAR(200),
Converted_opportunitites VARCHAR(200), 
Conversion_rate varchar(200), 
Number_of_records VARCHAR (200)
);

##KPI's##
# 1. Total expected amount
Select sum(expected_amount) as Total_amount from opportunity;

# 2. Active Opportunity
SELECT SUM(
  CASE 
    WHEN stage <> 'closed won' THEN 1 
    ELSE 0 
  END
) as active_opportunity 
from opportunity;

# 3. Conversion rate
SELECT Concat (ROUND (SUM(CASE WHEN created_by_lead_conversion = 'TRUE' THEN 1 ELSE 0 END) / COUNT(Opportunity_ID) *100,2), '%') 
as Opportunity_ratio
FROM opportunity;

# 4. Win rate
SELECT CONCAT(ROUND(SUM(CASE WHEN Won = 'true' THEN 1 ELSE 0 END) / COUNT(Won) * 100, 2), '%') as total_count
FROM opportunity;

# 5. loss rate
SELECT CONCAT(ROUND(SUM(CASE WHEN Won = 'false' THEN 1 ELSE 0 END) / COUNT(Won) * 100, 2), '%') as total_count
FROM opportunity;

# 6. opportunities by industry
SELECT 
    CASE 
        WHEN (industry) = '' THEN 'Others'
        ELSE industry
    END as industry,
    COUNT(opportunity_id) as total_opportunity
FROM opportunity
GROUP BY 
    CASE 
        WHEN (industry) = '' THEN 'Others'
        ELSE industry
    END
ORDER BY total_opportunity DESC
LIMIT 5;

# 7. total leads
select count(lead_id) from leads;

# 8. expected amount from converted leads
SELECT (SELECT SUM(expected_amount)
        FROM opportunity
        WHERE opportunity_ID IN (SELECT converted_opportunity_id FROM leads)
       ) AS total_expected_amount;
       
# 9. conversion rate
Select 
concat(sum(converted_accounts)/count(converted_accounts)*100, '%') 
as conversion_rate from leads;

# 10. converted accounts
select sum(converted_accounts) from leads; 

# 11. lead by source
select lead_source, count(lead_source) from leads
group by lead_source order by count(lead_source) DESC;

# 12. lead by industry
select industry , count(industry) from leads
group by industry order by count(industry) DESC limit 4;

# 13. converted opportunities
select sum(Converted_opportunitites)as converted_opportunity from leads;


##Trend Analysis KPI's  
# 1. Running Total Expected Vs Commit Forecast amount over time
	SELECT sub.fiscal_year,
		   sub.commit_total,
		   SUM(sub.commit_total) OVER (ORDER BY sub.fiscal_year) as running_commit_total
	FROM (
		SELECT fiscal_year,
			   SUM(CASE WHEN forecast_category1 = 'commit' THEN expected_amount ELSE 0 END) as commit_total
		FROM opportunity
		GROUP BY fiscal_year
	) as sub

#continuation
SELECT sub.fiscal_year,
       total,
       SUM(total) OVER (ORDER BY fiscal_year) as running_total
FROM (
    SELECT fiscal_year,
           SUM(expected_amount) as total
    FROM opportunity
    GROUP BY fiscal_year
) sub;

# 2. Running Total Active vs Total Opportunities over time
select sub.fiscal_year, active_opptotal, sum(active_opptotal) OVER (ORDER BY sub.fiscal_year) as running_total
from (select fiscal_year, sum(case when stage <> 'closed won' then 1 else 0 END) as active_opptotal from opportunity
group by fiscal_year ) as sub;

##Continuation
SELECT fiscal_year, total, 
       sum(total) OVER (ORDER BY fiscal_year) as running_total
FROM (
    SELECT fiscal_year, count(opportunity_id) as total
    FROM opportunity
    GROUP BY fiscal_year
) as sub;

## 3. Closed Won Vs Total Opportunities over time
select fiscal_year, closed_won, sum(closed_won) over (order by fiscal_year) from 
( select fiscal_year, sum(case 
when stage = 'closed won' then 1 else 0 END) as closed_won from opportunity group by fiscal_year order by fiscal_year) as sub;

#continuation
SELECT fiscal_year, total, 
       sum(total) OVER (ORDER BY fiscal_year) as running_total
FROM (
    SELECT fiscal_year, count(opportunity_id) as total
    FROM opportunity
    GROUP BY fiscal_year
) as sub;
