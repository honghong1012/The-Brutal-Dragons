-- (1) What’s the average police misconduct rate by district?
-- The chicago map is divided by police districts.
-- The misconduct rate of a district is defined as [allegation_count]/[population]/[police_population]*1000.
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


-- (2) What’s the average proportion of non-white police officers serving in the same area?
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



-- (3) Which districts have similar race demography?

-- Get the black-dominant district.
-- From the execution result, we can see district 8&11, 9&14 have a similar race distribution. They are predominantly black.
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

-- Get the white-predominant district.
-- From the execution result, we can see district 5,18 have a similar race distribution. They are predominantly white.
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

-- Get the asian-dominant district.
-- From the execution result, there is no district that is asian-dominant.But 2 and 15 has a similar race distribution with relatively high Asian proportion.
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
WHERE district_race_proportion.Asian > 0
ORDER BY district_race_proportion.Asian DESC;

-- Get the Hispanic-dominant district
-- From the execution result, we can see district 6,24 have a similar race distribution. They are predominantly hispanic.
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



-- (4) What’s the proportion of non-white police officers who are policing the above districts?
-- (5) What’s the misconduct rate in these districts?

-- District 8 and 11
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

-- District 9 and 14
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
WHERE data_policeunit.id - 1 in (9, 14)
GROUP BY data_policeunit.id, district_misconduct_rate;

-- District 2 and 15
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
WHERE data_policeunit.id - 1 in (2, 15)
GROUP BY data_policeunit.id, district_misconduct_rate;

-- District 5 and 18
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
WHERE data_policeunit.id - 1 in (5, 18)
GROUP BY data_policeunit.id, district_misconduct_rate;

-- District 6 and 24
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
WHERE data_policeunit.id - 1 in (6, 24)
GROUP BY data_policeunit.id, district_misconduct_rate;
