-- Combine march and april data
CREATE TABLE daily_activity AS
SELECT * FROM daily_activity_march
UNION ALL
SELECT * FROM daily_activity_april;

-- Check for duplicate Id + Date combinations
SELECT Id, ActivityDate, COUNT(*) as count
FROM daily_activity
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1;

-- Remove duplicates, keep first occurrence
CREATE TABLE daily_activity_clean AS
SELECT * FROM daily_activity
WHERE rowid IN (
    SELECT MIN(rowid)
    FROM daily_activity
    GROUP BY Id, ActivityDate
);

-- Remove zero step rows
CREATE TABLE daily_activity_final AS
SELECT * FROM daily_activity_clean
WHERE TotalSteps > 0;

-- Check for sleep duplicates
SELECT Id, SleepDay, COUNT(*) as count
FROM sleep_day
GROUP BY Id, SleepDay
HAVING COUNT(*) > 1;

-- Clean sleep data
CREATE TABLE sleep_day_clean AS
SELECT * FROM sleep_day
WHERE rowid IN (
    SELECT MIN(rowid)
    FROM sleep_day
    GROUP BY Id, SleepDay
);

-- Summary statistics
SELECT 
    ROUND(AVG(TotalSteps), 2) AS avg_steps,
    ROUND(AVG(Calories), 2) AS avg_calories,
    ROUND(AVG(SedentaryMinutes), 2) AS avg_sedentary,
    ROUND(AVG(LightlyActiveMinutes), 2) AS avg_lightly_active,
    ROUND(AVG(FairlyActiveMinutes), 2) AS avg_fairly_active,
    ROUND(AVG(VeryActiveMinutes), 2) AS avg_very_active
FROM daily_activity_final;

-- Count unique users
SELECT COUNT(DISTINCT Id) AS total_users
FROM daily_activity_final;

-- Per user analysis
SELECT 
    Id,
    ROUND(AVG(TotalSteps), 0) AS avg_steps,
    ROUND(AVG(Calories), 0) AS avg_calories,
    ROUND(AVG(SedentaryMinutes), 0) AS avg_sedentary,
    COUNT(*) AS days_tracked
FROM daily_activity_final
GROUP BY Id
ORDER BY avg_steps DESC;

-- Join activity and sleep data
SELECT 
    a.Id,
    ROUND(AVG(a.TotalSteps), 0) AS avg_steps,
    ROUND(AVG(a.SedentaryMinutes), 0) AS avg_sedentary,
    ROUND(AVG(s.TotalMinutesAsleep), 0) AS avg_minutes_asleep,
    ROUND(AVG(s.TotalTimeInBed), 0) AS avg_time_in_bed
FROM daily_activity_final a
INNER JOIN sleep_day_clean s
    ON a.Id = s.Id 
    AND a.ActivityDate = SUBSTR(s.SleepDay, 1, INSTR(s.SleepDay, ' ') - 1)
GROUP BY a.Id
ORDER BY avg_minutes_asleep DESC;
