SELECT *
From Layoffs


/*

Data Cleaning

*/

-- Building CTE to discover the duplicates 
WITH duplicate_CTE AS (

SELECT *,ROW_NUMBER() OVER( PARTITION BY company, [location], industry,total_laid_off,percentage_laid_off,stage, country, funds_raised_millions, [date] ORDER BY [date]) AS rankk
FROM layoffs
)


-- deleting all duplicates 
DELETE L
FROM layoffs L
JOIN duplicate_CTE D
    ON L.company = D.company
    AND L.[location] = D.[location]
    AND L.industry = D.industry
    AND L.total_laid_off = D.total_laid_off
    AND L.percentage_laid_off = D.percentage_laid_off
    AND L.stage = D.stage
    AND L.country = D.country
    AND L.funds_raised_millions = D.funds_raised_millions
    AND L.[date] = D.[date]
    AND D.rankk > 1;



-- Query 1: Showing company names 
SELECT DISTINCT company, TRIM(company)
FROM layoffs ;



-- Resetting company names
UPDATE layoffs
SET company = TRIM(company);


-- Query 2: showing industries 
SELECT DISTINCT industry 
FROM layoffs 
ORDER BY 1;


-- Update 'Crypto' in industry
UPDATE layoffs 
SET industry='Crypto'
WHERE industry LIKE 'Crypto%'


-- Query 3: showing country
SELECT DISTINCT country
FROM layoffs 
ORDER BY 1;


-- Update 'United States' in country
UPDATE layoffs 
SET country='United States'
WHERE country LIKE 'United States%'



-- Query 4: showing date column 
SELECT [date],CONVERT(DATE,[date])
FROM layoffs


-- Update data type for the next columns
ALTER TABLE layoffs
ALTER COLUMN [date] DATE;

ALTER TABLE layoffs
ALTER COLUMN funds_raised_millions FLOAT;


ALTER TABLE layoffs
ALTER COLUMN percentage_laid_off FLOAT;

ALTER TABLE layoffs
ALTER COLUMN total_laid_off INT;


-- Query 5: Showing the null values in percentage_laid_off
SELECT * 
FROM layoffs 
WHERE percentage_laid_off ='' OR percentage_laid_off = 'NULL'



-- Update 'NULL' and ' ' values to NULL in percentage_laid_off
UPDATE layoffs
SET percentage_laid_off  = NULL
WHERE percentage_laid_off  ='NULL' OR percentage_laid_off  = ' '



-- Query 6: Showing the null values in industry column with all columns 
SELECT * 
FROM layoffs l1 JOIN layoffs l2 ON l1.company = l2.company 
AND l2.industry IS NULL 



--Update The Null values in industry column 
UPDATE l1
SET l1.industry = (
    SELECT TOP 1 l2.industry
    FROM layoffs AS l2
    WHERE l1.company = l2.company AND l2.industry IS NOT NULL
)
FROM layoffs l1
WHERE l1.industry IS NULL;



--Making the industry value in company Bally's Interactive is Entertainment (given by searching) 
UPDATE layoffs
SET industry ='Entertainment'
WHERE company LIKE 'Bally%'





-- Query 7: Showing the distinct values in industry column 
SELECT DISTINCT industry
FROM layoffs 



-- Query 8: Showing companies which have NULL value in both percentage_laid_off and total_laid_off columns
SELECT company, COUNT(*) AS frequency 
FROM layoffs 
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL 
GROUP BY company


--Deleing unnecessary rows 
DELETE FROM layoffs
WHERE percentage_laid_off IS NULL 
AND total_laid_off IS NULL 




-- Replacing NULL values in percentage_laid_off with mean
UPDATE layoffs
SET percentage_laid_off = (
    SELECT ROUND(percentage_laid_off,2)
    FROM layoffs 
    WHERE percentage_laid_off IS NOT NULL
)
WHERE percentage_laid_off IS NULL;




-- Replacing NULL values in total_laid_off with mean
UPDATE layoffs
SET total_laid_off = (
    SELECT ROUND(total_laid_off ,0)
    FROM layoffs 
    WHERE total_laid_off IS NOT NULL
)
WHERE total_laid_off IS NULL;




-- Replacing NULL values in funds_raised_millions with mean
UPDATE layoffs
SET funds_raised_millions = (
    SELECT ROUND(funds_raised_millions,0)
    FROM layoffs 
    WHERE funds_raised_millions IS NOT NULL
)
WHERE funds_raised_millions IS NULL;



--Adding new column total_employees
ALTER TABLE layoffs
ADD total_employees INT;



-- Making new column to know the number of employees for each company (total_laid_off/percentage_laid_off)
UPDATE layoffs
SET total_employees = (total_laid_off / TRY_CONVERT(FLOAT, percentage_laid_off))
WHERE total_laid_off IS NOT NULL 
  AND TRY_CONVERT(FLOAT, percentage_laid_off) IS NOT NULL 
  AND TRY_CONVERT(FLOAT, percentage_laid_off) <> 0;



-- Handling null values in stage 
UPDATE layoffs
SET stage = 'Unknown'
WHERE stage IS NULL;



 


/*

Exploratory Analysis

*/

SELECT *
FROM layoffs 


-- Query 9: Maximum total laidoffs in one year **
SELECT TOP 1 company, date ,MAX(total_laid_off ) AS maximum_total_laid_offs
FROM layoffs
GROUP BY company, date
ORDER BY 3 DESC;



-- Query 10: The count of all companies that laidoff all them employees **
SELECT COUNT(company) fully_total_laid_offs_companies
FROM layoffs
WHERE percentage_laid_off  =1 ;


-- Query 11: Top 5 companies with the hieghst funds raised and laidoff all them employees  **
SELECT TOP 5 company,funds_raised_millions
FROM layoffs
WHERE percentage_laid_off =1  
ORDER BY funds_raised_millions DESC;


-- Query 12: What are the most 10 companies in total layoffs ?  **
SELECT TOP 10 company , SUM(CAST(total_laid_off AS INT)) 
FROM layoffs
GROUP BY company
ORDER BY 2 DESC;



-- Query 13: What are the total lay offs over time ?
SELECT YEAR([date]), SUM(CAST(total_laid_off AS INT)) 
FROM layoffs
GROUP BY YEAR([date])
HAVING YEAR([date]) IS NOT NULL
ORDER BY 1 DESC; 



-- Query 14: What is the date of the first and last layoff? **
SELECT MIN([date]) AS first_layoff, MAX([date]) AS last_layoff
FROM layoffs 




--Query 15: What are the most 5 stages have total layoffs? **
SELECT TOP 5 stage , SUM(total_laid_off)
FROM layoffs
GROUP BY stage
ORDER BY 2 DESC;