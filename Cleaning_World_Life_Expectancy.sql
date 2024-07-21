# World Life Expectancy Project (Data Cleaning & EDA)

-- Use Database
USE World_Life_Expectancy;

-- Look at all the data
SELECT * 
FROM World_Life_Expectancy;

-- Check for Duplicates 
SELECT 
	Country, 
    Year, 
    CONCAT(Country, Year), 
    COUNT(CONCAT(Country, Year))
FROM World_Life_Expectancy 
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country,Year)) > 1; 

-- Extract Row_ID from duplicate rows in order to delete the correct rows using subquery and row_number() and partition by function
SELECT *
FROM (
	SELECT 
		Row_ID,
		CONCAT(Country, Year),
		ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num 
	FROM World_Life_Expectancy) AS Row_Table
WHERE Row_Num > 1;

-- Delete duplicate rows 
DELETE FROM World_Life_Expectancy 
WHERE 
	Row_ID IN (
	SELECT Row_ID
FROM (
	SELECT Row_ID, 
    CONCAT(Country,Year), 
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country,Year)) AS Row_Num 
	FROM World_Life_Expectancy
    ) AS Row_Table
WHERE Row_Num > 1
); 

-- Identify blank values in 'Status' column
SELECT * 
FROM World_Life_Expectancy
WHERE Status = '';

-- Identify NULL values in 'Status' column
SELECT * 
FROM World_Life_Expectancy
WHERE Status IS NULL;

-- Check unique values in Status column. 
SELECT DISTINCT(Status) 
FROM World_Life_Expectancy
WHERE Status <> '';

-- Check unique values in Country column with the status 'Developing' 
SELECT DISTINCT(Country)
FROM World_Life_Expectancy
WHERE Status = 'Developing';

-- Filling blank status with developing if it matches with the rows of the same Country
UPDATE World_Life_Expectancy t1 
JOIN World_Life_Expectancy t2 
	ON t1.Country = t2.Country
SET t1.Status = 'Developing' 
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

-- Filling blank status with developed if it matches with the rows of the same Country
UPDATE World_Life_Expectancy t1 
JOIN World_Life_Expectancy t2 
	ON t1.Country = t2.Country
SET t1.Status = 'Developed' 
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

-- Check the data
SELECT * 
FROM World_Life_Expectancy
WHERE Status = '';

-- Blanks in Life expectancy column 
SELECT * 
FROM World_Life_Expectancy
WHERE `Life expectancy` = '';

-- Extract specific columns to identify ways to deal with missing values
SELECT 
	Country,
    Year,
    `Life expectancy`
FROM World_Life_Expectancy; 

-- Query to calculate the average life expectancy
SELECT 
	t1.Country, t1.Year, t1.`Life expectancy`, 
    t2.Country, t2.Year, t2.`Life expectancy`,
    t3.Country, t3.Year, t3.`Life expectancy`,
    ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) -- Calculating the average life expectancy for blank fields
FROM World_Life_Expectancy t1 
JOIN World_Life_Expectancy t2
	ON t1.Country = t2.Country 
    AND t1.Year = t2.Year - 1
JOIN World_Life_Expectancy t3
	ON t1.Country = t3.Country 
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''; 

-- Filling up the blank fields in Life expectancy column with the average value 
UPDATE World_Life_Expectancy t1 
JOIN World_Life_Expectancy t2
	ON t1.Country = t2.Country 
    AND t1.Year = t2.Year - 1
JOIN World_Life_Expectancy t3
	ON t1.Country = t3.Country 
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''; 

#Exploratory Data Analysis
-- Minimum and Maximum Life Expectancy of the respective countries
-- Extracting 0 for Min and Max Life Expectancy
SELECT
	Country, 
    MIN(`Life expectancy`) AS 'Min Life Expectancy',
    MAX(`Life expectancy`) AS 'Max Life Expectancy'
FROM World_Life_Expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) = 0 
AND MAX(`Life expectancy`) = 0
ORDER BY Country DESC; 

-- Minimum and Maximum Life Expectancy of the respective countries
-- Filter out data that does not have 0 for min and max life expectancy
SELECT
	Country, 
    MIN(`Life expectancy`) AS Min_Life_Expectancy,
    MAX(`Life expectancy`) AS Max_Life_Expectancy,
    (ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1)) AS Life_Increase_15_Yrs
FROM World_Life_Expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Yrs DESC;

-- Average Life Expectancy Yearly as a Whole
SELECT 
	Year, 
    ROUND(AVG(`Life expectancy`),2) AS Avg_Life_Expectancy 
FROM World_Life_Expectancy
GROUP BY Year 
ORDER BY Year; 

-- Correlation between Life Expectancy and GDP 
-- Life Expectancy in Ascending Order
SELECT
	Country, 
    ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Expectancy, 
    ROUND(AVG(GDP),1) AS Avg_GDP
FROM World_Life_Expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 
AND Avg_GDP > 0
ORDER BY Avg_Life_Expectancy ASC; 

-- Life Expectancy in Descending Order
SELECT
	Country, 
    ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Expectancy, 
    ROUND(AVG(GDP),1) AS Avg_GDP
FROM World_Life_Expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 
AND Avg_GDP > 0
ORDER BY Avg_Life_Expectancy DESC; 

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy, 
SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM World_Life_Expectancy; 

-- Correlation between Life Expectancy and Countries's Status
SELECT 
	Status,
    COUNT(DISTINCT(Country)) AS Countries,
    ROUND(AVG(`Life expectancy`),1) AS Avg_Life_Expectancy
FROM World_Life_Expectancy
GROUP BY Status;

-- Correlation between Life Expectancy and BMI 
SELECT 
	Country, 
    ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy, 
    ROUND(AVG(BMI),1) AS BMI 
FROM World_Life_Expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 
AND BMI > 0
ORDER BY BMI DESC; 

-- Correlation between Life Expectancy and Adult Mortality
SELECT 
	Country, 
    Year, 
	`Life expectancy`, 
    `Adult Mortality`,
    SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM World_Life_Expectancy
WHERE Country LIKE '%United%';