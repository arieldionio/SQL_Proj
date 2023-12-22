-- Analyzing the parts table to determine if the process requires adjustment.

-- Taking the columns needed and adding row numbers, average height and stddev of height column.
WITH CTE1 AS(
	SELECT
		operator,
		ROW_NUMBER() OVER(PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS row_num,
		height,
		AVG(height) OVER(PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS avg_height,
		STDDEV_SAMP(height) OVER(PARTITION BY operator ORDER BY item_no ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS stddev_height
	FROM parts),
    
-- Taking the upper and lower limit, and filtering the row number from 5 and above, because the first calculations didn't only have 4 and below.
CTE2 AS(
	SELECT *,  
		avg_height + (3 * (stddev_height / SQRT(5))) AS ucl, 
		avg_height - (3 * (stddev_height / SQRT(5))) AS lcl
	FROM CTE1
	WHERE row_num >= 5),

-- Creating a new column that returns if the height is outside the range of the upper and lower limit.
CTE3 AS(
SELECT *,
	CASE 
		WHEN height > ucl OR height < lcl 
        THEN True 
        ELSE False
	END AS alert
FROM CTE2)

-- result
SELECT *
FROM CTE3
WHERE alert IS TRUE
	