SELECT district_race_proportion.district, total, Black, White, Hispanic, Other, district_allegation_count, district_allegation_per_capita, police_population_by_district, district_misconduct_rate, police_Black, police_White, Police_Hispanic, Police_Asian, Police_Other, Police_Female
FROM (SELECT area_id - 1526                                                             AS district,
             SUM(count)                                                                 AS total,
             ROUND(SUM(count) filter (WHERE race = 'Asian/Pacific Islander') / (1.0 * SUM(count)), 4)    AS Other,
             ROUND(SUM(count) filter (WHERE race = 'Black') / (1.0 * SUM(count)), 4)    AS Black,
             ROUND(SUM(count) filter (WHERE race = 'White') / (1.0 * SUM(count)), 4)    AS White,
             ROUND(SUM(count) filter (WHERE race = 'Hispanic') / (1.0 * SUM(count)), 4) AS Hispanic
      FROM data_racepopulation
               LEFT JOIN data_area da on data_racepopulation.area_id = da.id
      WHERE da.area_type = 'police-districts'
      GROUP BY area_id) AS district_race_proportion
 LEFT JOIN (SELECT district_allegation.district,
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
                                             ON district_allegation.district = district_police.district) AS police_district_data
                         ON district_race_proportion.district = police_district_data.district
LEFT JOIN (
    SELECT data_policeunit.id - 1                                               AS district,
                COUNT(*)                                                             AS police_total,
                ROUND(COUNT(*) filter (WHERE race = 'Black') * 1.0 / COUNT(*), 4)    AS police_Black,
                ROUND(COUNT(*) filter (WHERE race = 'White') * 1.0 / COUNT(*), 4)    AS police_White,
                ROUND(COUNT(*) filter (WHERE race = 'Hispanic') * 1.0 / COUNT(*), 4) AS Police_Hispanic,
                ROUND(COUNT(*) filter (WHERE race = 'Asian/Pacific') * 1.0 / COUNT(*),
                      4)                                                             AS Police_Asian,
                ROUND(COUNT(*) filter (WHERE race = 'Other' or race = 'Native American/Alaskan Native') * 1.0 /
                      COUNT(*),
                      4)                                                             AS Police_Other,
                ROUND(COUNT(*) filter (WHERE gender = 'F') * 1.0 / COUNT(*), 4)      AS Police_Female
         FROM data_policeunit
                  LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
         WHERE data_policeunit.id > 1
           AND data_policeunit.id < 26
         GROUP BY data_policeunit.id
) AS district_police_demography ON district_police_demography.district = district_race_proportion.district
ORDER BY district_race_proportion.district ASC ;
