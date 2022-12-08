
# Checkpoint 1

In checkpoint 1, we use SQL to answer the question proposed in Relational Analytics section using PostgreSQL database. 

Before executing the code, you need to set up and connect CPDB database remotely,

## Descriptive Questions: 

### Q1: What’s the average police misconduct rate by district? 

The Chicago map is divided by police districts. The misconduct rate of a district is defined as `[allegation_count]/[population]/[police_population]*1000`.

```sql
SELECT AVG(district_misconduct_rate)
FROM (SELECT district_allegation.district,
             district_population,
             district_allegation_count,
             district_allegation_per_capita,
             police_population_by_district,
             ROUND(district_allegation_per_capita * 1000 / police_population_by_district,
                   4) AS district_misconduct_rate
      FROM (
               -- Get the allegation number per capita grouped by district
               SELECT data_allegation_areas.area_id - 1526          as district,
                      ap.area_population                            AS district_population,
                      COUNT(*)                                      AS district_allegation_count,
                      ROUND(COUNT(*) * 1.0 / ap.area_population, 4) AS district_allegation_per_capita
               FROM data_allegation_areas
                        LEFT JOIN data_area da ON data_allegation_areas.area_id = da.id
                        LEFT JOIN (SELECT area_id, SUM(count) AS area_population
                                   FROM data_racepopulation
                                   GROUP BY area_id) ap ON ap.area_id = da.id
               WHERE da.area_type = 'police-districts'
               GROUP BY data_allegation_areas.area_id, ap.area_population
               ORDER BY district) AS district_allegation
               LEFT JOIN (
          -- Get the police number grouped by district
          SELECT data_policeunit.id - 1 AS district, count(*) AS police_population_by_district
          FROM data_policeunit
                   LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
          WHERE data_policeunit.id > 1
            AND data_policeunit.id < 26
          GROUP BY data_policeunit.id) AS district_police
                         ON district_allegation.district = district_police.district) AS distinct_misconduct;
```

### Q2: What’s the average proportion of non-white police officers working in the same district?
The result also shows the average proportion of white, black, hispanic and other race police officers grouped by district. 
```sql
SELECT 1 - AVG(White) AS avg_nonwhite,
       AVG(White)     AS avg_white,
       AVG(Black)     AS avg_black,
       AVG(Hispanic)  AS avg_hispanic,
       AVG(Asian)        avg_asian
FROM (
         -- Get the police demographic data by district
         SELECT data_policeunit.id - 1                                               AS district,
                COUNT(*)                                                             AS total,
                ROUND(COUNT(*) filter (WHERE race = 'Black') * 1.0 / COUNT(*), 4)    AS Black,
                ROUND(COUNT(*) filter (WHERE race = 'White') * 1.0 / COUNT(*), 4)    AS White,
                ROUND(COUNT(*) filter (WHERE race = 'Hispanic') * 1.0 / COUNT(*), 4) AS Hispanic,
                ROUND(COUNT(*) filter (WHERE race = 'Asian/Pacific') * 1.0 / COUNT(*),
                      4)                                                             AS Asian,
                ROUND(COUNT(*) filter (WHERE race = 'Other' or race = 'Native American/Alaskan Native') * 1.0 /
                      COUNT(*),
                      4)                                                             AS Other,
                ROUND(COUNT(*) filter (WHERE gender = 'F') * 1.0 / COUNT(*), 4)      AS Female
         FROM data_policeunit
                  LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
         WHERE data_policeunit.id > 1
           AND data_policeunit.id < 26
         GROUP BY data_policeunit.id) AS district_police_demography;
```

###    Q3: Which districts have a similar race demography?
The SQL below shows the predominantly Black district.   
```sql
SELECT *
FROM (SELECT area_id - 1526                                                             AS district,
             SUM(count)                                                                 AS total,
             ROUND(SUM(count) filter (WHERE race = 'Asian') / (1.0 * SUM(count)), 4)    AS Asian,
             ROUND(SUM(count) filter (WHERE race = 'Black') / (1.0 * SUM(count)), 4)    AS Black,
             ROUND(SUM(count) filter (WHERE race = 'White') / (1.0 * SUM(count)), 4)    AS White,
             ROUND(SUM(count) filter (WHERE race = 'Hispanic') / (1.0 * SUM(count)), 4) AS Hispanic,
             ROUND(SUM(count) filter (WHERE race = 'Other') / (1.0 * SUM(count)), 4)    AS Other
      FROM data_racepopulation
               LEFT JOIN data_area da on data_racepopulation.area_id = da.id
      WHERE da.area_type = 'police-districts'
      GROUP BY area_id) AS district_race_proportion
WHERE district_race_proportion.Black > 0.5
ORDER BY district_race_proportion.Black DESC;
```

The similar code can show the predominantly White/Asian/Hispanic district.
```sql 
SELECT *
FROM (SELECT area_id - 1526                                                             AS district,
             SUM(count)                                                                 AS total,
             ROUND(SUM(count) filter (WHERE race = 'Asian') / (1.0 * SUM(count)), 4)    AS Asian,
             ROUND(SUM(count) filter (WHERE race = 'Black') / (1.0 * SUM(count)), 4)    AS Black,
             ROUND(SUM(count) filter (WHERE race = 'White') / (1.0 * SUM(count)), 4)    AS White,
             ROUND(SUM(count) filter (WHERE race = 'Hispanic') / (1.0 * SUM(count)), 4) AS Hispanic,
             ROUND(SUM(count) filter (WHERE race = 'Other') / (1.0 * SUM(count)), 4)    AS Other
      FROM data_racepopulation
               LEFT JOIN data_area da on data_racepopulation.area_id = da.id
      WHERE da.area_type = 'police-districts'
      GROUP BY area_id) AS district_race_proportion
WHERE district_race_proportion.White > 0.5
ORDER BY district_race_proportion.White DESC;
```
```sql
SELECT *
FROM (SELECT area_id - 1526                                                             AS district,
             SUM(count)                                                                 AS total,
             ROUND(SUM(count) filter (WHERE race = 'Asian') / (1.0 * SUM(count)), 4)    AS Asian,
             ROUND(SUM(count) filter (WHERE race = 'Black') / (1.0 * SUM(count)), 4)    AS Black,
             ROUND(SUM(count) filter (WHERE race = 'White') / (1.0 * SUM(count)), 4)    AS White,
             ROUND(SUM(count) filter (WHERE race = 'Hispanic') / (1.0 * SUM(count)), 4) AS Hispanic,
             ROUND(SUM(count) filter (WHERE race = 'Other') / (1.0 * SUM(count)), 4)    AS Other
      FROM data_racepopulation
               LEFT JOIN data_area da on data_racepopulation.area_id = da.id
      WHERE da.area_type = 'police-districts'
      GROUP BY area_id) AS district_race_proportion
WHERE district_race_proportion.Asian > 0.5
ORDER BY district_race_proportion.Asian DESC;
```
```sql
SELECT *
FROM (SELECT area_id - 1526                                                             AS district,
             SUM(count)                                                                 AS total,
             ROUND(SUM(count) filter (WHERE race = 'Asian') / (1.0 * SUM(count)), 4)    AS Asian,
             ROUND(SUM(count) filter (WHERE race = 'Black') / (1.0 * SUM(count)), 4)    AS Black,
             ROUND(SUM(count) filter (WHERE race = 'White') / (1.0 * SUM(count)), 4)    AS White,
             ROUND(SUM(count) filter (WHERE race = 'Hispanic') / (1.0 * SUM(count)), 4) AS Hispanic,
             ROUND(SUM(count) filter (WHERE race = 'Other') / (1.0 * SUM(count)), 4)    AS Other
      FROM data_racepopulation
               LEFT JOIN data_area da on data_racepopulation.area_id = da.id
      WHERE da.area_type = 'police-districts'
      GROUP BY area_id) AS district_race_proportion
WHERE district_race_proportion.Hispanic > 0.5
ORDER BY district_race_proportion.Hispanic DESC;
```

From the above code, we can manually choose some districts with similar race distributions. For example, we can see district 8 and 11 have nearly the same race distribution.

district| total | asian| black | white | hispanic | other
:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:
11|90841|0.0007|0.9745|0.0034|0.0101|0.0095
8|71071|0.0008|0.9679|0.0037|0.0164|0.0093

Other district pair can be 9&14, 2&15, 5&18, 6&24.

###    Q4: What’s the proportion of non-white police officers who are policing the above areas?
```sql
SELECT data_policeunit.id - 1                                                AS district,
       1 - ROUND(COUNT(*) filter (WHERE race = 'White') * 1.0 / COUNT(*), 4) AS non_white,
       ROUND(COUNT(*) filter (WHERE race = 'Black') * 1.0 / COUNT(*), 4)     AS Black,
       ROUND(COUNT(*) filter (WHERE race = 'White') * 1.0 / COUNT(*), 4)     AS White,
       ROUND(COUNT(*) filter (WHERE race = 'Hispanic') * 1.0 / COUNT(*), 4)  AS Hispanic,
       ROUND(COUNT(*) filter (WHERE gender = 'F') * 1.0 / COUNT(*), 4)       AS Female,
       district_misconduct_rate
FROM data_policeunit
         LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
         LEFT JOIN (SELECT district_allegation.district,
                           ROUND(district_allegation_per_capita * 1000 / police_population_by_district,
                                 4) AS district_misconduct_rate
                    FROM (
                             -- Get the allegation number per capita grouped by district
                             SELECT data_allegation_areas.area_id - 1526          as district,
                                    ap.area_population                            AS district_population,
                                    COUNT(*)                                      AS district_allegation_count,
                                    ROUND(COUNT(*) * 1.0 / ap.area_population, 4) AS district_allegation_per_capita
                             FROM data_allegation_areas
                                      LEFT JOIN data_area da ON data_allegation_areas.area_id = da.id
                                      LEFT JOIN (SELECT area_id, SUM(count) AS area_population
                                                 FROM data_racepopulation
                                                 GROUP BY area_id) ap ON ap.area_id = da.id
                             WHERE da.area_type = 'police-districts'
                             GROUP BY data_allegation_areas.area_id, ap.area_population
                             ORDER BY district) AS district_allegation
                             LEFT JOIN (
                        -- Get the police number grouped by district
                        SELECT data_policeunit.id - 1 AS district, count(*) AS police_population_by_district
                        FROM data_policeunit
                                 LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
                        WHERE data_policeunit.id > 1
                          AND data_policeunit.id < 26
                        GROUP BY data_policeunit.id) AS district_police
                                       ON district_allegation.district = district_police.district) AS distinct_misconduct
                   ON data_policeunit.id - 1 = distinct_misconduct.district
WHERE data_policeunit.id - 1 in (8, 11)
GROUP BY data_policeunit.id, district_misconduct_rate;
```

The above code shows the answer of district pair 8 and 11, which has a similar race demography. We can change the district number in line `WHERE data_policeunit.id - 1 in (8, 11)` and run the code again to see other pairs. 

The complete code can be found in `src/checkpoint1.sql` with comment.

###    Q5: What’s the misconduct rate in these district?

This question can be answer by the same SQL execution code of Q4. 

