-- checkpoint 4
-- Get the police demographic data by district
         SELECT unit_name, gender, race, major_award_count, trr_count, unsustained_count
         FROM data_policeunit
                  LEFT JOIN data_officer d ON data_policeunit.id = d.last_unit_id
         WHERE data_policeunit.id > 1 AND data_policeunit.id < 27