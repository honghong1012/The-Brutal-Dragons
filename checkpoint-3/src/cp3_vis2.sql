-- Checkpoint 3
-- Visualization#2 Extract the officer in certain area with their race, gender and the service time
-- District 6 and 24
SELECT data_policeunit.id, unit_name, gender, race,
       to_char(appointed_date, 'YYYY') as appointed_date,
       to_char(resignation_date, 'YYYY') as resigned_time
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
WHERE (data_policeunit.id - 1 in (6, 24) and appointed_date is not null and resignation_date is not null);

-- District 5 and 18
SELECT data_policeunit.id, unit_name, gender, race,
       to_char(appointed_date, 'YYYY') as appointed_date,
       to_char(resignation_date, 'YYYY') as resigned_time
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
WHERE (data_policeunit.id - 1 in (5, 18) and appointed_date is not null and resignation_date is not null);

-- District 8 and 11
SELECT data_policeunit.id, unit_name, gender, race,
       to_char(appointed_date, 'YYYY') as appointed_date,
       to_char(resignation_date, 'YYYY') as resigned_time
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
WHERE (data_policeunit.id - 1 in (8, 11) and appointed_date is not null and resignation_date is not null);

-- District 9 and 14
SELECT data_policeunit.id, unit_name, gender, race,
       to_char(appointed_date, 'YYYY') as appointed_date,
       to_char(resignation_date, 'YYYY') as resigned_time
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
WHERE (data_policeunit.id - 1 in (9, 14) and appointed_date is not null);

-- District 2 and 15
SELECT data_policeunit.id, unit_name, gender, race,
       to_char(appointed_date, 'YYYY') as appointed_date,
       to_char(resignation_date, 'YYYY') as resigned_time
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
WHERE (data_policeunit.id - 1 in (2, 15) and appointed_date is not null);