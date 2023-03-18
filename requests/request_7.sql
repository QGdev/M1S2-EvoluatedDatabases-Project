------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Population moyenne par tranche d’âge par pays 

SELECT p.country_name, a.age_group, AVG(f.population_count) AS MoyPopulation, DENSE_RANK() OVER (PARTITION BY a.age_group ORDER BY(AVG(f.population_count)) DESC) AS rank
FROM FACTS f, COUNTRIES p, AGE_GROUPS a
WHERE p.id_country = f.id_country AND f.id_age_group = a.id_age_group AND f.population_count IS NOT NULL AND a.age_group <> 'TOTAL'
GROUP BY (p.country_name, a.age_group)
ORDER BY rank;
