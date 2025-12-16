#Full Smartwatch Data Cleaning SQL Project 

USE test ;
SELECT DATABASE();

SELECT * FROM unclean_smartwatch_health_data;

SELECT count(*) FROM unclean_smartwatch_health_data
WHERE `User ID` IS NULL OR `User ID` = '';

-- deleting nulls or empty User ID  
DELETE FROM unclean_smartwatch_health_data
WHERE `User ID` IS NULL OR `User ID` = '';

 -- removing the duplicates 
DROP TABLE IF EXISTS smartwatch_health_data;
CREATE TABLE smartwatch_health_data AS
SELECT DISTINCT *
FROM unclean_smartwatch_health_data;

SELECT * FROM smartwatch_health_data;

-- replacing Values in Activity Level 
UPDATE smartwatch_health_data
SET `Activity Level` = REPLACE(`Activity Level`, '_', ' ');

UPDATE smartwatch_health_data
SET`Activity Level` = REPLACE(`Activity Level`, 'Actve', 'Active');

UPDATE smartwatch_health_data
SET `Activity Level` = REPLACE(`Activity Level`, 'Seddentary', 'Sedentary');

SELECT * FROM smartwatch_health_data;

-- showing non-numeric values 
SELECT DISTINCT `Stress Level`
FROM smartwatch_health_data
WHERE `Stress Level` IS NOT NULL
  AND `Stress Level` NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';

-- unifying the rows in Stress level 
UPDATE smartwatch_health_data
SET `Stress Level` = 9
WHERE `Stress Level` = 'Very High';


# REPLACING NULL VALUES AND EMPTY ROWS 


-- replacing the null or empty rows with cloumn mode 
SELECT `Stress Level`
INTO @mode_stress
FROM smartwatch_health_data
WHERE `Stress Level` IS NOT NULL
  AND `Stress Level` != ''
GROUP BY `Stress Level`
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT @mode_stress;

UPDATE smartwatch_health_data
SET `Stress Level` = @mode_stress
WHERE `Stress Level` IS NULL
   OR `Stress Level` = '';
   
-- COUNT NULL VALUES IN Sleep Duration 
SELECT count(*)
FROM smartwatch_health_data
WHERE `Sleep Duration (hours)` = '' OR `Sleep Duration (hours)` IS NULL;

-- REPLACING THE NULL AND EMPTY ROWS WITH CLOUMN Median 
WITH ordered AS (
    SELECT 
        `Sleep Duration (hours)` ,
        ROW_NUMBER() OVER (ORDER BY `Sleep Duration (hours)`) AS rn,
        COUNT(*) OVER () AS cnt
    FROM smartwatch_health_data
    WHERE `Sleep Duration (hours)` IS NOT NULL
      AND `Sleep Duration (hours)` != ''
)
SELECT AVG(`Sleep Duration (hours)`)
INTO @median_sleep
FROM ordered
WHERE rn IN ((cnt + 1) DIV 2, (cnt + 2) DIV 2);

UPDATE smartwatch_health_data
SET `Sleep Duration (hours)` = @median_sleep
WHERE `Sleep Duration (hours)` IS NULL
   OR `Sleep Duration (hours)` = '';

SELECT * FROM smartwatch_health_data;


-- COUNT NULL VALUES IN Step Duration 
SELECT count(*)
FROM smartwatch_health_data
WHERE `Step Count` = '' OR `Step Count` IS NULL;

-- REPLACING THE NULL AND EMPTY ROWS WITH CLOUMN Median 
WITH ordered_step AS (
    SELECT 
        `Step Count` ,
        ROW_NUMBER() OVER (ORDER BY `Step Count`) AS rn,
        COUNT(*) OVER () AS cnt
    FROM smartwatch_health_data
    WHERE `Step Count` IS NOT NULL
      AND `Step Count` != ''
)
SELECT AVG(`Step Count`)
INTO @median_step
FROM ordered_step
WHERE rn IN ((cnt + 1) DIV 2, (cnt + 2) DIV 2);

UPDATE smartwatch_health_data
SET `Step Count` = @median_step
WHERE `Step Count` IS NULL
   OR `Step Count` = '';

SELECT * FROM smartwatch_health_data;

-- COUNT NULL VALUES IN Blood Oxygen Level Duration 
SELECT count(*)
FROM smartwatch_health_data
WHERE `Blood Oxygen Level (%)` = '' OR `Blood Oxygen Level (%)` IS NULL;

-- REPLACING THE NULL AND EMPTY ROWS WITH CLOUMN Median 
WITH ordered_blood AS (
    SELECT 
        `Blood Oxygen Level (%)` ,
        ROW_NUMBER() OVER (ORDER BY `Blood Oxygen Level (%)`) AS rn,
        COUNT(*) OVER () AS cnt
    FROM smartwatch_health_data
    WHERE `Blood Oxygen Level (%)` IS NOT NULL
      AND `Blood Oxygen Level (%)` != ''
)
SELECT AVG(`Blood Oxygen Level (%)`)
INTO @median_blood
FROM ordered_blood
WHERE rn IN ((cnt + 1) DIV 2, (cnt + 2) DIV 2);

UPDATE smartwatch_health_data
SET `Blood Oxygen Level (%)` = @median_blood
WHERE `Blood Oxygen Level (%)` IS NULL
   OR `Blood Oxygen Level (%)` = '';
   
SELECT * FROM smartwatch_health_data;

-- COUNT NULL VALUES IN Heart Rate Duration 
SELECT count(*)
FROM smartwatch_health_data
WHERE `Heart Rate (BPM)` = '' OR `Heart Rate (BPM)` IS NULL;

-- REPLACING THE NULL AND EMPTY ROWS WITH CLOUMN Median 
WITH ordered_heart AS (
    SELECT 
        `Heart Rate (BPM)` ,
        ROW_NUMBER() OVER (ORDER BY `Heart Rate (BPM)`) AS rn,
        COUNT(*) OVER () AS cnt
    FROM smartwatch_health_data
    WHERE `Heart Rate (BPM)` IS NOT NULL
      AND `Heart Rate (BPM)` != ''
)
SELECT AVG(`Heart Rate (BPM)`)
INTO @median_heart
FROM ordered_heart
WHERE rn IN ((cnt + 1) DIV 2, (cnt + 2) DIV 2);

UPDATE smartwatch_health_data
SET `Heart Rate (BPM)` = @median_heart
WHERE `Heart Rate (BPM)` IS NULL
   OR `Heart Rate (BPM)` = '';

SELECT * FROM smartwatch_health_data;


-- CHANGING TYPEs 

ALTER TABLE smartwatch_health_data
MODIFY COLUMN `Stress Level` INT;

ALTER TABLE smartwatch_health_data
MODIFY COLUMN `Sleep Duration (hours)` decimal(5,2);

ALTER TABLE smartwatch_health_data
MODIFY COLUMN `Step Count` INT;

ALTER TABLE smartwatch_health_data
MODIFY COLUMN `Blood Oxygen Level (%)` decimal(5,2);

ALTER TABLE smartwatch_health_data
MODIFY COLUMN `Heart Rate (BPM)` decimal(5,2);

SELECT * FROM smartwatch_health_data;

# Removing the Outliers 
-- Heart Rate between 40 and 220
DELETE FROM smartwatch_health_data
WHERE `Heart Rate (BPM)` < 40 OR `Heart Rate (BPM)` > 220;

-- Blood Oxygen between 70 and 100
DELETE FROM smartwatch_health_data
WHERE `Blood Oxygen Level (%)` < 70 OR `Blood Oxygen Level (%)` > 100;

-- Step Count >= 0
DELETE FROM smartwatch_health_data
WHERE `Step Count` < 0;

-- Sleep Duration between 0 and 24
DELETE FROM smartwatch_health_data
WHERE `Sleep Duration (hours)` <= 0 OR `Sleep Duration (hours)` > 24;

-- Stress Level between 1 and 10
DELETE FROM smartwatch_health_data
WHERE `Stress Level` < 1 OR `Stress Level` > 10;









