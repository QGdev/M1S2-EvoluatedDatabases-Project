------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Le RNB par pays par année

SELECT p.country_name, f.year, SUM(f.gni*f.population_count)
FROM COUNTRIES p, FACTS f, AGE_GROUPS a
WHERE p.id_country = f.id_country AND f.id_age_group = a.id_age_group AND a.age_group='TOTAL' AND f.gni IS NOT NULL AND f.population_count IS NOT NULL
GROUP BY ROLLUP(p.country_name,f.year);