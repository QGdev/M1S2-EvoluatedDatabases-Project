------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Cumul du co2 produit par pays et par année

SELECT p.country_name, f.year, f.co2 *f.population_count AS CO2, SUM(f.co2 * f.population_count) OVER (ORDER BY f.year ROWS UNBOUNDED PRECEDING) AS CUMUL_CO2
FROM COUNTRIES p, FACTS f, AGE_GROUPS a
WHERE f.id_country = p.id_country AND f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.population_count IS NOT NULL AND f.co2 IS NOT NULL
ORDER BY p.country_name, f.year;
