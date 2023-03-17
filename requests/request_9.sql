------------------------------------------------------
--  PROJET BDDE 2022-2023
--
--      GOMES DOS REIS Quentin
--      LECRIVAIN Mattheo
--      POUPLIN Gabriel
--      MEUNIER Rodrigue
--
------------------------------------------------------
--Le top 10 des pays avec le plus gros RNB en 2021

SELECT *
FROM (SELECT p.country_name, SUM(f.gni*f.population_count) AS gni
FROM FACTS f, COUNTRIES p, AGE_GROUPS a
WHERE f.id_country = p.id_country AND f.id_age_group = a.id_age_group AND a.age_group = 'TOTAL' AND f.year=2021 AND f.population_count IS NOT NULL AND f.gni IS NOT NULL
GROUP BY p.country_name
ORDER BY gni DESC)
WHERE ROWNUM <= 10;

